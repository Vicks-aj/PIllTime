import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_model.dart';
import '../models/medication_log_model.dart';

class MedicationService {
  static const String _medicationsKey = 'medications';
  static const String _medicationLogsKey = 'medication_logs';

  // Medication CRUD operations
  Future<List<MedicationModel>> getAllMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = prefs.getString(_medicationsKey);

      if (medicationsJson != null) {
        final List<dynamic> medicationsList = jsonDecode(medicationsJson);
        return medicationsList
            .map((json) => MedicationModel.fromJson(json))
            .where((med) => med.isActive)
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting medications: $e');
      return [];
    }
  }

  Future<bool> addMedication(MedicationModel medication) async {
    try {
      final medications = await getAllMedications();
      medications.add(medication);
      await _saveMedications(medications);

      // Generate medication logs for the next 30 days
      await _generateMedicationLogs(medication);

      return true;
    } catch (e) {
      print('Error adding medication: $e');
      return false;
    }
  }

  Future<bool> updateMedication(MedicationModel medication) async {
    try {
      final medications = await getAllMedications();
      final index = medications.indexWhere((med) => med.id == medication.id);

      if (index != -1) {
        medications[index] = medication.copyWith(updatedAt: DateTime.now());
        await _saveMedications(medications);

        // Regenerate logs for updated medication
        await _generateMedicationLogs(medication);

        return true;
      }

      return false;
    } catch (e) {
      print('Error updating medication: $e');
      return false;
    }
  }

  Future<bool> deleteMedication(String medicationId) async {
    try {
      final medications = await getAllMedications();
      final updatedMedications = medications.map((med) {
        if (med.id == medicationId) {
          return med.copyWith(isActive: false, updatedAt: DateTime.now());
        }
        return med;
      }).toList();

      await _saveMedications(updatedMedications);
      return true;
    } catch (e) {
      print('Error deleting medication: $e');
      return false;
    }
  }

  // Medication Log operations
  Future<List<MedicationLogModel>> getTodaysMedicationLogs() async {
    try {
      final logs = await getAllMedicationLogs();
      final today = DateTime.now();

      return logs.where((log) {
        return log.scheduledTime.year == today.year &&
            log.scheduledTime.month == today.month &&
            log.scheduledTime.day == today.day;
      }).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      print('Error getting today\'s logs: $e');
      return [];
    }
  }

  Future<List<MedicationLogModel>> getAllMedicationLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_medicationLogsKey);

      if (logsJson != null) {
        final List<dynamic> logsList = jsonDecode(logsJson);
        return logsList
            .map((json) => MedicationLogModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting medication logs: $e');
      return [];
    }
  }

  Future<bool> markMedicationAsTaken(String logId) async {
    try {
      final logs = await getAllMedicationLogs();
      final index = logs.indexWhere((log) => log.id == logId);

      if (index != -1) {
        logs[index] = logs[index].copyWith(
          isTaken: true,
          takenTime: DateTime.now(),
        );
        await _saveMedicationLogs(logs);
        return true;
      }

      return false;
    } catch (e) {
      print('Error marking medication as taken: $e');
      return false;
    }
  }

  Future<bool> markMedicationAsSkipped(String logId, String? reason) async {
    try {
      final logs = await getAllMedicationLogs();
      final index = logs.indexWhere((log) => log.id == logId);

      if (index != -1) {
        logs[index] = logs[index].copyWith(
          isSkipped: true,
          notes: reason,
        );
        await _saveMedicationLogs(logs);
        return true;
      }

      return false;
    } catch (e) {
      print('Error marking medication as skipped: $e');
      return false;
    }
  }

  // Helper methods
  Future<void> _saveMedications(List<MedicationModel> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsJson =
        jsonEncode(medications.map((med) => med.toJson()).toList());
    await prefs.setString(_medicationsKey, medicationsJson);
  }

  Future<void> _saveMedicationLogs(List<MedicationLogModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = jsonEncode(logs.map((log) => log.toJson()).toList());
    await prefs.setString(_medicationLogsKey, logsJson);
  }

  Future<void> _generateMedicationLogs(MedicationModel medication) async {
    try {
      final existingLogs = await getAllMedicationLogs();
      final newLogs = <MedicationLogModel>[];

      // Filter out future logs for this medication that haven't been taken/skipped
      // We want to regenerate these to ensure accuracy after updates
      final filteredLogs = existingLogs.where((log) {
        // Keep logs that are from the past OR have already been taken/skipped
        return log.medicationId != medication.id ||
            log.isTaken ||
            log.isSkipped ||
            log.scheduledTime.isBefore(DateTime.now().subtract(
                Duration(minutes: 1))); // Keep past logs with a small buffer
      }).toList();

      // Determine the effective start date for generating new logs
      // Start from the medication's start date, but not before the beginning of today
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      final effectiveLogGenerationStartDate = medication.startDate
              .isAfter(startOfToday)
          ? medication.startDate
          : startOfToday; // Start from the beginning of today if medication started in past or today

      // Generate logs for the next 30 days (or until endDate)
      for (int day = 0; day < 31; day++) {
        // Generate for today + 30 days
        final currentDate = DateTime(
          effectiveLogGenerationStartDate.year,
          effectiveLogGenerationStartDate.month,
          effectiveLogGenerationStartDate.day,
        ).add(Duration(days: day));

        // Stop if current date is after medication end date
        if (medication.endDate != null &&
            currentDate.isAfter(medication.endDate!)) {
          break;
        }

        // Generate logs for each reminder time
        for (String timeString in medication.reminderTimes) {
          final timeParts = timeString.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          final scheduledDateTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
          );

          // Only add if it's not a duplicate of an existing log that was kept
          // (e.g., already taken/skipped, or a past log)
          final isDuplicate = filteredLogs.any((log) =>
              log.medicationId == medication.id &&
              log.scheduledTime.year == scheduledDateTime.year &&
              log.scheduledTime.month == scheduledDateTime.month &&
              log.scheduledTime.day == scheduledDateTime.day &&
              log.scheduledTime.hour == scheduledDateTime.hour &&
              log.scheduledTime.minute == scheduledDateTime.minute);

          if (!isDuplicate) {
            final log = MedicationLogModel(
              id: '${medication.id}_${scheduledDateTime.millisecondsSinceEpoch}',
              medicationId: medication.id,
              scheduledTime: scheduledDateTime,
              createdAt: DateTime.now(),
            );
            newLogs.add(log);
          }
        }
      }

      // Save updated logs
      filteredLogs.addAll(newLogs);
      await _saveMedicationLogs(filteredLogs);
    } catch (e) {
      print('Error generating medication logs: $e');
    }
  }

  // Get medication by ID
  Future<MedicationModel?> getMedicationById(String id) async {
    try {
      final medications = await getAllMedications();
      return medications.firstWhere(
        (med) => med.id == id,
        orElse: () => throw Exception('Medication not found'),
      );
    } catch (e) {
      print('Error getting medication by ID: $e');
      return null;
    }
  }

  // Get adherence statistics
  Future<Map<String, dynamic>> getAdherenceStats() async {
    try {
      final logs = await getAllMedicationLogs();
      final last7Days = DateTime.now().subtract(Duration(days: 7));

      final recentLogs = logs
          .where((log) =>
              log.scheduledTime.isAfter(last7Days) &&
              log.scheduledTime.isBefore(DateTime.now()))
          .toList();

      final totalDoses = recentLogs.length;
      final takenDoses = recentLogs.where((log) => log.isTaken).length;
      final skippedDoses = recentLogs.where((log) => log.isSkipped).length;
      final missedDoses = recentLogs
          .where((log) =>
              !log.isTaken &&
              !log.isSkipped &&
              DateTime.now().isAfter(log.scheduledTime))
          .length;

      final adherenceRate =
          totalDoses > 0 ? (takenDoses / totalDoses * 100).round() : 0;

      return {
        'totalDoses': totalDoses,
        'takenDoses': takenDoses,
        'skippedDoses': skippedDoses,
        'missedDoses': missedDoses,
        'adherenceRate': adherenceRate,
      };
    } catch (e) {
      print('Error getting adherence stats: $e');
      return {
        'totalDoses': 0,
        'takenDoses': 0,
        'skippedDoses': 0,
        'missedDoses': 0,
        'adherenceRate': 0,
      };
    }
  }
}

class MedicationLogModel {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool isTaken;
  final bool isSkipped;
  final String? notes;
  final DateTime createdAt;

  MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.isTaken = false,
    this.isSkipped = false,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'isTaken': isTaken,
      'isSkipped': isSkipped,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    return MedicationLogModel(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      takenTime:
          json['takenTime'] != null ? DateTime.parse(json['takenTime']) : null,
      isTaken: json['isTaken'] ?? false,
      isSkipped: json['isSkipped'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  MedicationLogModel copyWith({
    String? id,
    String? medicationId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    bool? isTaken,
    bool? isSkipped,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationLogModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      isTaken: isTaken ?? this.isTaken,
      isSkipped: isSkipped ?? this.isSkipped,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get status {
    if (isTaken) return 'Taken';
    if (isSkipped) return 'Skipped';
    if (DateTime.now().isAfter(scheduledTime)) return 'Missed';
    return 'Scheduled';
  }

  @override
  String toString() {
    return 'MedicationLogModel(id: $id, medicationId: $medicationId, isTaken: $isTaken)';
  }
}

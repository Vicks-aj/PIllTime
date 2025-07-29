class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String color; // Keep as String to match existing code
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationModel({
    String? id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.notes,
    this.color = '#1E3A8A', // Default blue color as hex string
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _generateId(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Add the missing frequencyDisplay getter
  String get frequencyDisplay {
    switch (frequency) {
      case 'Once daily':
        return '1x daily';
      case 'Twice daily':
        return '2x daily';
      case 'Three times daily':
        return '3x daily';
      case 'Four times daily':
        return '4x daily';
      case 'Every other day':
        return 'Every other day';
      case 'Weekly':
        return 'Weekly';
      case 'As needed':
        return 'As needed';
      default:
        return frequency;
    }
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      reminderTimes: List<String>.from(json['reminderTimes']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      notes: json['notes'],
      color: json['color'] ?? '#1E3A8A',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'reminderTimes': reminderTimes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MedicationModel copyWith({
    String? name,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? color,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return MedicationModel(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

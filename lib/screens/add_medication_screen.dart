import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  final _startDateController =
      TextEditingController(); // New controller for start date
  final _endDateController =
      TextEditingController(); // New controller for end date

  String _frequency = 'Once daily';
  List<String> _reminderTimes = ['08:00'];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _medicationColor = '#1E3A8A'; // Changed to string
  bool _isLoading = false;

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every other day',
    'Weekly',
    'As needed',
  ];

  final Map<String, Color> _colorOptions = {
    '#1E3A8A': Color(0xFF1E3A8A), // Primary blue
    '#10B981': Color(0xFF10B981), // Green
    '#F59E0B': Color(0xFFF59E0B), // Yellow
    '#EF4444': Color(0xFFEF4444), // Red
    '#A78BFA': Color(0xFFA78BFA), // Purple
    '#06B6D4': Color(0xFF06B6D4), // Cyan
    '#F97316': Color(0xFFF97316), // Orange
    '#84CC16': Color(0xFF84CC16), // Lime
  };

  final MedicationService _medicationService = MedicationService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateFormat('MMM d, y').format(_startDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _updateReminderTimes() {
    setState(() {
      switch (_frequency) {
        case 'Once daily':
          _reminderTimes = ['08:00'];
          break;
        case 'Twice daily':
          _reminderTimes = ['08:00', '20:00'];
          break;
        case 'Three times daily':
          _reminderTimes = ['08:00', '14:00', '20:00'];
          break;
        case 'Four times daily':
          _reminderTimes = ['08:00', '12:00', '16:00', '20:00'];
          break;
        case 'Every other day':
          _reminderTimes = ['08:00'];
          break;
        case 'Weekly':
          _reminderTimes = ['08:00'];
          break;
        case 'As needed':
          _reminderTimes = [];
          break;
      }
    });
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_reminderTimes[index].split(':')[0]),
        minute: int.parse(_reminderTimes[index].split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTimes[index] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate
          : (_endDate ?? _startDate.add(Duration(days: 30))),
      firstDate: DateTime.now()
          .subtract(Duration(days: 365)), // Allow past dates for start date
      lastDate: DateTime.now()
          .add(Duration(days: 365 * 5)), // 5 years into the future
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('MMM d, y').format(_startDate);
          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = _startDate;
            _endDateController.text = DateFormat('MMM d, y').format(_endDate!);
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('MMM d, y').format(_endDate!);
          // Ensure end date is not before start date
          if (_endDate!.isBefore(_startDate)) {
            _endDate = _startDate;
            _endDateController.text = DateFormat('MMM d, y').format(_endDate!);
          }
        }
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final medication = MedicationModel(
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          frequency: _frequency,
          reminderTimes: _reminderTimes,
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.trim(),
          color: _medicationColor, // Now string
        );

        final success = await _medicationService.addMedication(medication);

        if (success) {
          // Schedule notifications
          await _notificationService.scheduleMedicationReminders(medication);

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medication added successfully!'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add medication. Please try again.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Text(
          'Add Medication',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    _buildCard(
                      'Basic Information',
                      [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Medication Name',
                            hintText: 'e.g., Aspirin, Vitamin D',
                            prefixIcon: Icon(Icons.medication,
                                color: Color(0xFF1E3A8A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF1E3A8A), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medication name';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _dosageController,
                          decoration: InputDecoration(
                            labelText: 'Dosage',
                            hintText: 'e.g., 100mg, 1 tablet',
                            prefixIcon: Icon(Icons.local_pharmacy,
                                color: Color(0xFF1E3A8A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF1E3A8A), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Schedule Card
                    _buildCard(
                      'Schedule',
                      [
                        DropdownButtonFormField<String>(
                          value: _frequency,
                          decoration: InputDecoration(
                            labelText: 'Frequency',
                            prefixIcon:
                                Icon(Icons.schedule, color: Color(0xFF1E3A8A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF1E3A8A), width: 2),
                            ),
                          ),
                          items: _frequencies.map((String frequency) {
                            return DropdownMenuItem<String>(
                              value: frequency,
                              child: Text(frequency),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _frequency = newValue;
                              });
                              _updateReminderTimes();
                            }
                          },
                        ),

                        if (_reminderTimes.isNotEmpty) ...[
                          SizedBox(height: 16),
                          Text(
                            'Reminder Times',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 12),
                          ..._reminderTimes.asMap().entries.map((entry) {
                            int index = entry.key;
                            String time = entry.value;
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _selectTime(index),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E3A8A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            Color(0xFF1E3A8A).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Color(0xFF1E3A8A)),
                                      SizedBox(width: 12),
                                      Text(
                                        DateFormat('h:mm a').format(DateTime(
                                            2023,
                                            1,
                                            1,
                                            int.parse(time.split(':')[0]),
                                            int.parse(time.split(':')[1]))),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.edit,
                                          color: Color(0xFF1E3A8A), size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        SizedBox(height: 16),
                        // Start Date Field
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _startDateController,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: Color(0xFF1E3A8A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Color(0xFF1E3A8A), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a start date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // End Date Field (Optional)
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _endDateController,
                              decoration: InputDecoration(
                                labelText: 'End Date (Optional)',
                                hintText: 'Select an end date',
                                prefixIcon:
                                    Icon(Icons.event, color: Color(0xFF1E3A8A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Color(0xFF1E3A8A), width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Customization Card
                    _buildCard(
                      'Customization',
                      [
                        Text(
                          'Color',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colorOptions.entries.map((entry) {
                            String colorHex = entry.key;
                            Color color = entry.value;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _medicationColor = colorHex;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _medicationColor == colorHex
                                        ? Color(0xFF111827)
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: _medicationColor == colorHex
                                    ? Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Any additional information...',
                            prefixIcon:
                                Icon(Icons.note, color: Color(0xFF1E3A8A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF1E3A8A), width: 2),
                            ),
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),

                    SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),

            // Fixed Bottom Button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMedication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Saving...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Save Medication',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

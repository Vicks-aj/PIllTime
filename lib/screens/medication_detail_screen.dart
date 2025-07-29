import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../models/medication_log_model.dart';
import '../services/medication_service.dart';

class MedicationDetailScreen extends StatefulWidget {
  @override
  _MedicationDetailScreenState createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  final MedicationService _medicationService = MedicationService();
  List<MedicationLogModel> _recentLogs = [];
  bool _isLoading = true;
  late MedicationModel medication;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    medication = ModalRoute.of(context)!.settings.arguments as MedicationModel;
    _loadRecentLogs();
  }

  Future<void> _loadRecentLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allLogs = await _medicationService.getAllMedicationLogs();
      final medicationLogs = allLogs
          .where((log) => log.medicationId == medication.id)
          .toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      // Get last 7 days of logs
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final recentLogs = medicationLogs
          .where((log) => log.scheduledTime.isAfter(sevenDaysAgo))
          .take(20)
          .toList();

      setState(() {
        _recentLogs = recentLogs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recent logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'blue':
        return Color(0xFF2196F3);
      case 'green':
        return Color(0xFF4CAF50);
      case 'orange':
        return Color(0xFFFF9800);
      case 'purple':
        return Color(0xFF9C27B0);
      case 'red':
        return Color(0xFFF44336);
      case 'teal':
        return Color(0xFF009688);
      default:
        return Color(0xFF2196F3);
    }
  }

  String _getLogStatusText(MedicationLogModel log) {
    if (log.isTaken) return 'Taken';
    if (log.isSkipped) return 'Skipped';
    if (DateTime.now().isAfter(log.scheduledTime)) return 'Missed';
    return 'Scheduled';
  }

  Color _getLogStatusColor(MedicationLogModel log) {
    if (log.isTaken) return Color(0xFF4CAF50);
    if (log.isSkipped) return Colors.orange;
    if (DateTime.now().isAfter(log.scheduledTime)) return Colors.red;
    return Color(0xFF2196F3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _getColorFromString(medication.color),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          medication.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getColorFromString(medication.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          medication.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                      Icons.local_pharmacy, 'Dosage', medication.dosage),
                  SizedBox(height: 12),
                  _buildDetailRow(
                      Icons.schedule, 'Frequency', medication.frequencyDisplay),
                  SizedBox(height: 12),
                  _buildDetailRow(Icons.access_time, 'Times',
                      medication.reminderTimes.join(', ')),
                  SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today, 'Started',
                      '${medication.startDate.day}/${medication.startDate.month}/${medication.startDate.year}'),
                  if (medication.endDate != null) ...[
                    SizedBox(height: 12),
                    _buildDetailRow(Icons.event, 'Ends',
                        '${medication.endDate!.day}/${medication.endDate!.month}/${medication.endDate!.year}'),
                  ],
                  if (medication.notes != null &&
                      medication.notes!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      medication.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Recent Activity
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),

            SizedBox(height: 16),

            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_recentLogs.isEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Color(0xFFCCCCCC),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your medication history will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentLogs.length,
                itemBuilder: (context, index) {
                  final log = _recentLogs[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _buildLogCard(log),
                  );
                },
              ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Color(0xFF777777),
        ),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogCard(MedicationLogModel log) {
    final statusColor = _getLogStatusColor(log);
    final statusText = _getLogStatusText(log);
    final isToday = log.scheduledTime.day == DateTime.now().day &&
        log.scheduledTime.month == DateTime.now().month &&
        log.scheduledTime.year == DateTime.now().year;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isToday
                          ? 'Today'
                          : '${log.scheduledTime.day}/${log.scheduledTime.month}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      TimeOfDay.fromDateTime(log.scheduledTime).format(context),
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (log.isTaken && log.takenTime != null) ...[
                      SizedBox(width: 8),
                      Text(
                        'at ${TimeOfDay.fromDateTime(log.takenTime!).format(context)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

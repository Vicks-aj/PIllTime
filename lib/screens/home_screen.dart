import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_log_model.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MedicationService _medicationService = MedicationService();
  List<MedicationLogModel> _todaysLogs = [];
  List<MedicationLogModel> _upcomingLogs = [];
  Map<String, dynamic> _adherenceStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await _medicationService.getTodaysMedicationLogs();
      final stats = await _medicationService.getAdherenceStats();

      // Get upcoming medications (next 3 hours)
      final now = DateTime.now();
      final upcoming = logs
          .where((log) =>
              log.scheduledTime.isAfter(now) &&
              log.scheduledTime.isBefore(now.add(Duration(hours: 3))) &&
              !log.isTaken &&
              !log.isSkipped)
          .take(3)
          .toList();

      setState(() {
        _todaysLogs = logs;
        _upcomingLogs = upcoming;
        _adherenceStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsTaken(String logId) async {
    final success = await _medicationService.markMedicationAsTaken(logId);
    if (success) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medication marked as taken!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _markAsSkipped(String logId) async {
    final success = await _medicationService.markMedicationAsSkipped(
        logId, 'Skipped by user');
    if (success) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medication marked as skipped'),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Color(0xFF1E3A8A),
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Color(0xFF1E3A8A),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'PillTime',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadData,
                      ),
                    ],
                  ),

                  // Content
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Welcome Card
                        _buildWelcomeCard(),
                        SizedBox(height: 20),

                        // Quick Stats Row
                        _buildQuickStatsRow(),
                        SizedBox(height: 20),

                        // Next Reminder Card
                        if (_upcomingLogs.isNotEmpty) ...[
                          _buildNextReminderCard(),
                          SizedBox(height: 20),
                        ],

                        // Today's Medications
                        _buildSectionHeader(
                            'Today\'s Medications', '/medications'),
                        SizedBox(height: 12),

                        if (_todaysLogs.isEmpty)
                          _buildEmptyState()
                        else
                          ..._todaysLogs
                              .map((log) => _buildMedicationCard(log))
                              .toList(),

                        SizedBox(height: 20),

                        // Adherence Card
                        if (_adherenceStats.isNotEmpty) _buildAdherenceCard(),

                        SizedBox(height: 100), // Space for FAB
                      ]),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-medication')
              .then((_) => _loadData());
        },
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Add Medication'),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Stay healthy, stay consistent',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.medication,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    final todayTaken = _todaysLogs.where((log) => log.isTaken).length;
    final todayTotal = _todaysLogs.length;
    final adherenceRate = _adherenceStats['adherenceRate'] ?? 0;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Today', '$todayTaken/$todayTotal', 'Taken',
                Color(0xFF10B981))),
        SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Adherence', '$adherenceRate%', 'This week',
                Color(0xFF1E3A8A))),
        SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Streak', '7', 'Days', Color(0xFFF59E0B))),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextReminderCard() {
    final nextLog = _upcomingLogs.first;
    final timeUntil = nextLog.scheduledTime.difference(DateTime.now());

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF1E3A8A).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.schedule,
              color: Color(0xFF1E3A8A),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                FutureBuilder<MedicationModel?>(
                  future: _medicationService
                      .getMedicationById(nextLog.medicationId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      );
                    }
                    return Text('Loading...');
                  },
                ),
                SizedBox(height: 2),
                Text(
                  'in ${timeUntil.inMinutes} minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF9CA3AF),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, route),
          child: Text(
            'View All',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(MedicationLogModel log) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: log.isTaken
              ? Color(0xFF10B981)
              : log.isSkipped
                  ? Color(0xFFF59E0B)
                  : Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: log.isTaken
                  ? Color(0xFF10B981)
                  : log.isSkipped
                      ? Color(0xFFF59E0B)
                      : Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              log.isTaken
                  ? Icons.check
                  : log.isSkipped
                      ? Icons.close
                      : Icons.medication,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<MedicationModel?>(
                  future:
                      _medicationService.getMedicationById(log.medicationId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final medication = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            medication.dosage,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      );
                    }
                    return Text('Loading...');
                  },
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(log.scheduledTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (!log.isTaken && !log.isSkipped) ...[
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _markAsTaken(log.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: Size(70, 32),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text('Take', style: TextStyle(fontSize: 12)),
                ),
                SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _markAsSkipped(log.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFF59E0B),
                    side: BorderSide(color: Color(0xFFF59E0B)),
                    minimumSize: Size(70, 32),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text('Skip', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: log.isTaken
                    ? Color(0xFF10B981).withOpacity(0.1)
                    : Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                log.isTaken ? 'Taken' : 'Skipped',
                style: TextStyle(
                  color: log.isTaken ? Color(0xFF10B981) : Color(0xFFF59E0B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdherenceCard() {
    final adherenceRate = _adherenceStats['adherenceRate'] ?? 0;
    final takenDoses = _adherenceStats['takenDoses'] ?? 0;
    final totalDoses = _adherenceStats['totalDoses'] ?? 0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAdherenceColor(adherenceRate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$adherenceRate%',
                  style: TextStyle(
                    color: _getAdherenceColor(adherenceRate),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: adherenceRate / 100,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
                _getAdherenceColor(adherenceRate)),
            minHeight: 8,
          ),
          SizedBox(height: 12),
          Text(
            '$takenDoses of $totalDoses doses taken this week',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
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
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.medication_outlined,
              size: 40,
              color: Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No medications today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first medication to get started with reminders',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-medication')
                  .then((_) => _loadData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: Text('Add Medication'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Color _getAdherenceColor(int rate) {
    if (rate >= 80) return Color(0xFF10B981);
    if (rate >= 60) return Color(0xFFF59E0B);
    return Color(0xFFEF4444);
  }
}

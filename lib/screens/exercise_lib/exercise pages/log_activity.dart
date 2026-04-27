import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/models/log_routine.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/responsive_layout.dart';
import 'log_workout_popup.dart';

class LogActivityPage extends StatefulWidget {
  final int userId;

  const LogActivityPage({
  super.key,
  required this.userId,
  });

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  final DBHelper _dbHelper = DBHelper();
  List<WorkoutLog> _workoutHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      final history = await _dbHelper.getRecentWorkoutHistory(widget.userId);
      setState(() {
        _workoutHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout history: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshHistory() async {
    setState(() => _isLoading = true);
    await _loadWorkoutHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Unified AppBar
      appBar: const CustomAppBar(title: "mHealth"),

      // ✅ Responsive body
      body: ResponsiveLayout(
        child: RefreshIndicator(
          onRefresh: _refreshHistory,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Log Activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Log any workouts you complete here. Recent workouts appear below. "
                        "A full exercise history is available in the Activity Stats page.",
                  ),
                  const SizedBox(height: 8),

                  // Log button
                  GestureDetector(
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (_) => LogWorkoutPopup(userId: widget.userId),
                      );
                      if (result == true) await _refreshHistory();
                    },
                    child: const Text(
                      "+ Log a Workout",
                      style: TextStyle(
                        color: Color(0xFF6B578C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Exercise History",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6B578C)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Table content
                  _buildHistoryTable(),
                ],
              ),
            ),
          ),
        ),
      ),

      // ✅ Unified BottomNavBar
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildHistoryTable() {
    final Color lightPurple = Colors.deepPurple.shade50;
    final Color mediumPurple = Colors.deepPurple.shade100;

    if (_isLoading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
            AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400),
          ),
        ),
      );
    }

    if (_workoutHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: lightPurple,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.fitness_center,
                  size: 48, color: Colors.deepPurple.shade300),
              const SizedBox(height: 16),
              Text(
                'No workout history yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap "Log a Workout" above to get started!',
                style: TextStyle(color: Colors.deepPurple.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: mediumPurple,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: ["Workout", "Date", "Duration", "Calories"]
                      .map(
                        (e) => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(e,
                          style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),

          // Dynamic rows
          ...List.generate(_workoutHistory.length, (index) {
            final log = _workoutHistory[index];
            final rowColor = index.isEven ? lightPurple : Colors.white;

            return Container(
              decoration: BoxDecoration(
                color: rowColor,
                borderRadius: index == _workoutHistory.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(8))
                    : null,
              ),
              child: InkWell(
                onTap: () => _showWorkoutDetails(log),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        _cell(log.routineName),
                        _cell(log.formattedDate),
                        _cell(log.formattedDuration),
                        _cell(log.formattedCalories),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _cell(String text) => Padding(
    padding: const EdgeInsets.all(12.0),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
  );

  void _showWorkoutDetails(WorkoutLog log) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workout Details',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Routine Name:', log.routineName),
                _buildDetailRow('Date:', log.formattedDate),
                _buildDetailRow('Duration:', log.formattedDuration),
                if (log.caloriesBurned != null)
                  _buildDetailRow(
                      'Calories Burned:', '${log.formattedCalories} cal'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B578C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

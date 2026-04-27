import 'package:flutter/material.dart';
import 'package:mhealthapp/health/health_package.dart';

// Unified layout components
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/bottom_nav_bar.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  HealthSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final summary = await HealthAPI.getTodaySummary();
    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,



      bottomNavigationBar: const BottomNavBar(currentIndex: 3),

      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _summary == null
              ? const Center(child: Text("No health data available"))
              : SingleChildScrollView(
            child: Column(
              children: [
                _buildHealthCard(
                  "Steps",
                  "${_summary!.totalSteps}",
                  Icons.directions_walk,
                ),
                _buildHealthCard(
                  "Distance",
                  "${_summary!.totalDistance.toStringAsFixed(2)} km",
                  Icons.straighten,
                ),
                _buildHealthCard(
                  "Calories",
                  "${_summary!.totalCalories}",
                  Icons.local_fire_department,
                ),
                _buildHealthCard(
                  "Heart Rate",
                  "${_summary!.averageHeartRate} BPM",
                  Icons.favorite,
                ),
                _buildHealthCard(
                  "Sleep",
                  "${_summary!.sleepHours.toStringAsFixed(1)} hours",
                  Icons.bedtime,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

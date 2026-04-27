import 'package:flutter/material.dart';
import 'package:mhealthapp/health/health_package.dart';
import 'package:mhealthapp/screens/home_page.dart';
import 'package:mhealthapp/screens/auth/permission.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mhealthapp/services/health_data_sync_service.dart';

// Unified Widgets
import '../../widgets/custom_app_bar.dart';
import '../../widgets/responsive_layout.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({Key? key}) : super(key: key);

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool? _hasPermissions;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isChecking = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final granted = await HealthPermissions.checkPermissions();
      print("Permissions check result: $granted");

      if (granted) {
        await HealthDataSyncService.syncToSQLite();

        await Workmanager().registerPeriodicTask(
          "healthSyncTask",
          "syncHealthData",
          frequency: const Duration(minutes: 30),
        );
        print("today's Periodic task registered");

        await Workmanager().registerPeriodicTask(
          "yesterdayhealthSyncTask",
          "syncYesterdayHealthData",
          frequency: const Duration(hours: 24),
        );
        print("yesterday's Periodic task registered");
      } else {
        print("Permissions not granted, skipping task registration.");
      }

      setState(() {
        _hasPermissions = granted;
        _isChecking = false;
      });

      print(
        "State updated: _hasPermissions=$_hasPermissions, _isChecking=$_isChecking",
      );
    } catch (e) {
      setState(() {
        _hasPermissions = false;
        _isChecking = false;
      });
      print("Error while checking permissions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ----------------------------
    // LOADING STATE
    // ----------------------------
    if (_isChecking || _hasPermissions == null) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,



        body: ResponsiveLayout(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 24),
                Text(
                  'Health Data Tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Initializing...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ----------------------------
    // FINAL NAVIGATION
    // ----------------------------
    return _hasPermissions! ? HomePage() : const PermissionPage();
  }
}

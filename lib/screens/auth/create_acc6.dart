import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:mhealthapp/health/health_package.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mhealthapp/services/health_data_sync_service.dart';

// Unified layout widgets
import '../../../widgets/responsive_layout.dart';

class CreateAccountStep6 extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CreateAccountStep6({super.key, required this.userData});

  @override
  State<CreateAccountStep6> createState() => _CreateAccountStep6State();
}

class _CreateAccountStep6State extends State<CreateAccountStep6> {
  bool _isLoading = false;

  Future<void> _finishSignupAndRequestPermissions(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // If userId is not already saved from signup flow, try fetching from DB using email
      if (prefs.getInt('userId') == null && widget.userData['email'] != null) {
        final dbHelper = DBHelper();
        final user = await dbHelper.getUserByEmail(
          widget.userData['email'].toString().trim(),
        );

        if (user != null) {
          await prefs.setInt('userId', user['user_dim_id']);
          await prefs.setString(
            'logged_in_user_email',
            widget.userData['email'].toString().trim(),
          );
          await prefs.setBool('isLoggedIn', true);
        }
      }

      // On Android only: check Health Connect is installed
      if (Platform.isAndroid) {
        bool isInstalled = await HealthPermissions.isHealthConnectInstalled();
        if (!isInstalled) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showHealthConnectDialog(context);
          return;
        }
      }

      bool granted = await HealthPermissions.requestPermissions();

      if (granted) {
        await HealthDataSyncService.syncToSQLite();

        await Workmanager().registerPeriodicTask(
          "healthSyncTask",
          "syncHealthData",
          frequency: const Duration(minutes: 30),
        );

        await Workmanager().registerPeriodicTask(
          "yesterdayHealthSyncTask",
          "syncYesterdayHealthData",
          frequency: const Duration(hours: 24),
        );

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permission denied. Please grant health permissions to continue.',
            ),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/startup', (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting permissions: $e')),
      );
    }
  }

  void _showHealthConnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Connect Required'),
        content: const Text(
          'Health Connect must be installed to use health features.\n\n'
          'Please search "Health Connect by Android" in Google Play Store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Create an Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Congratulations, you have finished setting up your account! Click the 'Get Started' button to proceed to the home page.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'images/success.png',
                  height: 350,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      await _finishSignupAndRequestPermissions(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Get Started",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
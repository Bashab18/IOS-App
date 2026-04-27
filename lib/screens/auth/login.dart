import 'package:flutter/material.dart';
import 'package:mhealthapp/main.dart';
import 'package:mhealthapp/screens/auth/startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:mhealthapp/health/health_package.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mhealthapp/services/health_data_sync_service.dart';

// Unified Widgets
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/responsive_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String hashPassword(String password) {
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    final hashedPassword = hashPassword(password);

    if (email.isEmpty || hashedPassword.isEmpty) {
      _showError("Please enter both email and password");
      return;
    }

    final dbHelper = DBHelper();
    final user = await dbHelper.getUserByEmail(email);

    if (user != null && user['pwd'] == hashedPassword) {
      final prefs = await SharedPreferences.getInstance();

// only clear old login keys, not everything
      await prefs.remove('userId');
      await prefs.remove('logged_in_user_email');

      await prefs.setInt('userId', user['user_dim_id']);
      await prefs.setString('logged_in_user_email', email);
      await prefs.setBool('remember_me', _rememberMe);
      await prefs.setBool('isLoggedIn', true);

      await _requestPermissions();
    } else {
      _showError("Invalid email or password");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;

    });

    try {
      // On Android only: verify Health Connect is installed
      if (Platform.isAndroid) {
        bool isInstalled = await HealthPermissions.isHealthConnectInstalled();
        if (!isInstalled) {
          setState(() {
            _errorMessage =
                'Health Connect is not installed. Please install "Health Connect by Android" from Google Play';
            _isLoading = false;
          });
          _showHealthConnectDialog();
          return;
        }
      }

      bool granted = await HealthPermissions.requestPermissions();

      if (granted) {
        if (mounted) {
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

          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = Platform.isIOS
              ? 'Permission denied. Please grant access in Settings > Health > mHealth.'
              : 'Permission denied. Please grant permissions manually in Health Connect';
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/startup');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error requesting permissions: $e';
        _isLoading = false;
      });
    }
  }

  void _showHealthConnectDialog() {
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: ListView(
              children: [
                const SizedBox(height: 60),

                Text(
                  "Login",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Email
                const Text(
                  "Email",
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                const Text(
                  "Password",
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (val) {
                        setState(() {
                          _rememberMe = val!;
                        });
                      },
                      activeColor: Colors.deepPurple,
                    ),
                    const Text("Remember me"),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup1');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text(
                    "Don’t have an account? Click here to create one.",
                    style: TextStyle(
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

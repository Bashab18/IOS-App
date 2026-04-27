import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String> _next() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userId = prefs.getInt('userId');

    if (isLoggedIn && userId != null) {
      return '/home';
    }

    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _next(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        Future.microtask(() {
          Navigator.pushNamedAndRemoveUntil(
            context,
            snap.data!,
                (route) => false,
          );
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
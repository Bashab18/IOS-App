import 'package:flutter/material.dart';
import 'create_acc3.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Unified widgets
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';

class CreateAccountStep2 extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CreateAccountStep2({super.key, required this.userData});

  @override
  State<CreateAccountStep2> createState() => _CreateAccountStep2State();
}

class _CreateAccountStep2State extends State<CreateAccountStep2> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    widget.userData['username'] = _usernameController.text;
    String password = _passwordController.text;

    String hashPassword(String password) {
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    final hashedPassword = hashPassword(password);
    widget.userData['pwd'] = hashedPassword;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountStep3(userData: widget.userData),
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
          child: ListView(
            children: [
              Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              Text(
                "Next, create a username and password.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 24),

              // Username
              Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Password
              Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
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
              SizedBox(height: 16),

              Text(
                "Your password must:\n"
                    "- Be at least 10 characters long\n"
                    "- Contain both uppercase and lowercase letters\n"
                    "- Contain at least 1 number\n"
                    "- Contain at least 1 special character\n"
                    "- Not contain your email or username",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),

              SizedBox(height: 32),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

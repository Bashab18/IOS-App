import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/widgets/custom_app_bar.dart';
import 'package:mhealthapp/widgets/bottom_nav_bar.dart';
import 'package:mhealthapp/widgets/responsive_layout.dart';

import '../challenges.dart';
import 'ai_agent.dart';
import 'user_info.dart';
import 'contacts.dart';
import 'faq.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        username = 'Unknown User';
        email = 'unknown@example.com';
      });
      return;
    }

    final dbHelper = DBHelper();
    final userData = await dbHelper.getUserById(userId);

    setState(() {
      username = userData?['username'] ?? 'Unknown User';
      email = userData?['email'] ?? 'unknown@example.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 375;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"), // ✅ Unified AppBar
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // ✅ Unified Bottom Nav Bar

      body: ResponsiveLayout(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              // Title
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 20 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // ------------------- Profile Section -------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6B578C),
                    ),
                    child: ClipOval(
                      child: Image.asset('images/user.jpeg', fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username ?? 'Unknown User',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email ?? 'unknown@example.com',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),

              // ------------------- Settings Options -------------------
              ...[
                {'title': 'AI Agent', 'page': const AIAgentPage()},
                {'title': 'User Information', 'page': const UserInfo()},
                {'title': 'Contacts & Additional Information', 'page': const ContactsPage()},
                {'title': 'Frequently Asked Questions', 'page': const FAQPage()},
              ].map((item) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item['page'] as Widget),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),

              const SizedBox(height: 24),

              // ------------------- Master Reset -------------------
              ElevatedButton(
                onPressed: () => _showMasterResetDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade100,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(child: Text("Master Reset")),
              ),

              const SizedBox(height: 16),

              // ------------------- Logout -------------------
              ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(child: Text("Logout")),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- Dialogs -------------------

  void _showMasterResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Master Reset',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B578C),
          ),
        ),
        content: const Text(
          'Requesting a Master Reset will clear your progress, preferences, and chatbot interactions. '
              'This action is not automatic. Once submitted, your request will be reviewed by our team for confirmation. '
              'You’ll be notified once it’s approved and processed.\n\nAre you sure you want to request a reset?',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B578C)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFF6B578C), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add master reset logic here
            },
            child: const Text('Yes'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B578C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B578C),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?\n\nYou’ll need to log in again to access your personalized mHealth features.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B578C)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFF6B578C), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              }
            },
            child: const Text('Yes'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B578C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

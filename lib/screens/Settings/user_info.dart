import 'package:flutter/material.dart';
import 'package:mhealthapp/screens/Settings/user_info/edit_chat_summary.dart';
import 'package:mhealthapp/screens/Settings/user_info/edit_goal_setting.dart';
import 'package:mhealthapp/screens/Settings/user_info/edit_health_info.dart';
import 'package:mhealthapp/screens/Settings/user_info/edit_psnl_info.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/responsive_layout.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      body: ResponsiveLayout(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'User Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const Divider(height: 32),

              // PERSONAL DETAILS
              ListTile(
                title: const Text('Personal Details'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditPersonalInfoPage(),
                    ),
                  );
                },
              ),
              const Divider(),

              // USER CHAT SUMMARY
              ListTile(
                title: const Text('User Chat Summary'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConversationSummaryPage(),
                    ),
                  );
                },
              ),
              const Divider(),

              // HEALTH INFO
              ListTile(
                title: const Text('Health Information'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthInfo(),
                    ),
                  );
                },
              ),
              const Divider(),

              // GOAL SETTING
              ListTile(
                title: const Text('Goal Setting'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoalSetting(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// ✅ Shared widgets
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/responsive_layout.dart';

// ✅ Pages
import 'ActivityStats/activity_page.dart';
import 'Settings/settings_1.dart';
import 'challenges.dart';
import 'exercise.dart';
import 'exercise_lib/exercise_lib.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "mHealth"),
      body: const ResponsiveLayout(
        child: _HomeContent(),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      children: [
        // Welcome header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            "Welcome to mHealth!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth < 400 ? 22 : 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Hero image
        Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'images/home_page1.png',
            fit: BoxFit.cover,
            height: screenWidth < 500 ? 180 : 250,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        _buildActionButton(
          context,
          Icons.chat_bubble_outline,
          "Chat with mHealth AI",
              () {},
        ),

        _buildActionButton(
          context,
          Icons.list,
          "View your Exercises",
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExercisePage()),
            );
          },
        ),

        _buildActionButton(
          context,
          Icons.bar_chart,
          "View your Activity",
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ActivityPage()),
            );
          },
        ),

        _buildActionButtonWithProgress(
          context,
          Icons.settings,
          "Personalize your profile",
          0.7,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ---------------- Reusable Buttons ----------------
  Widget _buildActionButton(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonWithProgress(
      BuildContext context,
      IconData icon,
      String title,
      double progress,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.black),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                color: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

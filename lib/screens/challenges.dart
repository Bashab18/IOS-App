import 'package:flutter/material.dart';
import 'ActivityStats/activity_page.dart';
import 'Settings/settings_1.dart';
import 'badges.dart';
import 'home_page.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 375;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"), // ✅ Unified App Bar
      bottomNavigationBar:
      const BottomNavBar(currentIndex: 3), // ✅ Unified Bottom Nav Bar
      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Achievements Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Achievements",
                    style: TextStyle(
                      fontSize: 20 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BadgesPage()),
                      );
                    },
                    child: const Text(
                      "See more",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildAchievement(
                        "assets/stamina_queen.png", "Stamina Queen", textScale),
                    _buildAchievement(
                        "assets/leg_burner.png", "Leg Burner", textScale),
                    _buildAchievement(
                        "assets/abs_killer.png", "Abs Killer", textScale),
                    _buildAchievement(
                        "assets/3_day_streak.png", "3 Day Streak", textScale),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                "Challenges",
                style: TextStyle(
                  fontSize: 20 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildChallengeItem(
                  "assets/walking_master.png",
                  "Walking Master",
                  "Walk 5 miles",
                  1,
                  context,
                  textScale),
              _buildChallengeItem(
                  "assets/calorie_cruncher.png",
                  "Calorie Cruncher",
                  "Burn 500 calories",
                  1.0,
                  context,
                  textScale),
              _buildChallengeItem(
                  "assets/stepping_stone.png",
                  "Stepping Stone",
                  "Walk 10,000 steps",
                  0.3,
                  context,
                  textScale),
              _buildChallengeItem(
                  "assets/on_fire.png",
                  "On Fire",
                  "10 reps of arm hammers",
                  0.2,
                  context,
                  textScale),
              _buildChallengeItem(
                  "assets/tree_poser.png",
                  "Tree Poser",
                  "Perfect tree pose for 60s",
                  0.1,
                  context,
                  textScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievement(String imagePath, String label, double scale) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12 * scale),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(String imagePath, String title, String subtitle,
      double progress, BuildContext context, double scale) {
    return InkWell(
      onTap: () {
        if (progress == 1.0) {
          showCongratulationsDialog(context, 'You completed $title! 🎉');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16 * scale, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14 * scale)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.shade50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCongratulationsDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Image.asset('Images/cup.png', height: 100),
                  const SizedBox(height: 24),
                  const Text(
                    "Congratulations!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style:
                    TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Okay",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

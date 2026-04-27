import 'package:flutter/material.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 375;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/profile_image.png'),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Progress",
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: 0.6,
                color: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade50,
              ),

              const SizedBox(height: 16),

              Text(
                "Badges",
                style: TextStyle(
                  fontSize: 20 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: List.generate(18, (index) {
                    if (index == 0) {
                      // 🏅 Earned badge
                      return Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/on_a_roll.png'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "On a Roll",
                            style: TextStyle(fontSize: 14 * textScale),
                          ),
                        ],
                      );
                    } else {
                      // 🔒 Locked badges
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Badge",
                            style: TextStyle(
                              fontSize: 14 * textScale,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

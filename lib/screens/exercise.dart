import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'ActivityStats/activity_page.dart';
import 'Settings/settings_1.dart';
import 'challenges.dart';
import 'exercise_lib/exercise_lib.dart';
import 'exercise_lib/exercise pages/create_workout.dart';
import '/screens/home_page.dart';
import 'exercise_lib/exercise pages/log_activity.dart';
import '../main.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  /// One place to define what "back" means on this page
  void _goBackToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 375;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBackToHome(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "mHealth"),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),

        body: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Top-left back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => _goBackToHome(context),
                ),

                Text(
                  "Exercise",
                  style: TextStyle(
                    fontSize: 20 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // --- View Exercise Library ---
                ElevatedButton(
                  onPressed: () async {
                    if (await NavigationHelper.ensureUserLoggedIn(context)) {
                      final userId = await NavigationHelper.getCurrentUserId();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExerciseLibraryPage(userId: userId!),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Center(child: Text("View Exercise Library")),
                ),

                const SizedBox(height: 16),

                // --- Create Workout Routine ---
                ElevatedButton(
                  onPressed: () async {
                    if (await NavigationHelper.ensureUserLoggedIn(context)) {
                      final userId = await NavigationHelper.getCurrentUserId();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateWorkoutPage(userId: userId!),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Center(child: Text("Create Workout Routine")),
                ),

                const SizedBox(height: 16),

                // --- Log Activity ---
                ElevatedButton(
                  onPressed: () async {
                    if (await NavigationHelper.ensureUserLoggedIn(context)) {
                      final userId = await NavigationHelper.getCurrentUserId();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogActivityPage(userId: userId!),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Center(child: Text("Log Activity")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

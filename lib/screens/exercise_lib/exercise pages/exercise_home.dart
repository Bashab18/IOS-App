/*import 'create_workout.dart';
import 'package:flutter/material.dart';

class ExerciseHomePage extends StatelessWidget {
  const ExerciseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Exercise'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Activity'),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const SizedBox(height: 24),
            const Text(
              'Exercise',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // View Exercise Library Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xD7B0A6CA),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('View Exercise Library'),
            ),

            const SizedBox(height: 16),

            // Create Workout Routine Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const CreateWorkoutPage(),
                )
                );
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xD7B0A6CA),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Create Workout Routine'),

            ),

            const SizedBox(height: 16),

            // Log Activity Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B578C),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Log Activity'),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Icon(Icons.emoji_events, color: Color(0xFF6B578C), size: 48), // Trophy Icon
      ),
      title: const Text(
        'mHealth',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(Icons.settings, color: Color(0xFF6B578C), size: 48), // Gear Icon
        ),
      ],
    );
  }
}
*/
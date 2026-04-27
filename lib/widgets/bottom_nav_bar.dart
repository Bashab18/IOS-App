import 'package:flutter/material.dart';
import '../chatbot/chatbot.dart';
import '../screens/home_page.dart';
import '../screens/exercise.dart';
import '../screens/ActivityStats/activity_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Prevent reloading the same page

    switch (index) {
      case 0: // 🏠 Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;

      case 1: // 💬 Chat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotPage()),
        );
        break;

      case 2: // 🏋️ Exercise
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExercisePage()),
        );
        break;

      case 3: // 📊 Activity
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ActivityPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Activity',
          ),
        ],
      ),
    );
  }
}

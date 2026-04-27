// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import '../screens/challenges.dart';
import '../screens/Settings/settings_1.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomAppBar({
  super.key,
  required this.title,
  this.showBackButton = false,
  this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,

      // Left icon — Trophy or Back button
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBack ?? () => Navigator.pop(context),
      )
          : IconButton(
        icon: const Icon(Icons.emoji_events_outlined, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChallengesPage()),
          );
        },
      ),

      // Center title
      title: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),

      // Right icon — Settings
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

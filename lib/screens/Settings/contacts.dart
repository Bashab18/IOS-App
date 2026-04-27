import 'package:flutter/material.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/responsive_layout.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'Contacts & Additional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 20),
                const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('email@email.com'),
                const Text('(xxx) xxx-xxxx'),

                const SizedBox(height: 24),
                const Text('Resources', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                const LinkText('link to resource'),
                const LinkText('link to resource'),
                const LinkText('link to resource'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LinkText extends StatelessWidget {
  final String text;
  const LinkText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

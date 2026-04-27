import 'package:flutter/material.dart';
import 'package:mhealthapp/screens/ActivityStats/activity_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/responsive_layout.dart';
import '../exercise.dart';

class AIAgentPage extends StatefulWidget {
  const AIAgentPage({super.key});

  @override
  State<AIAgentPage> createState() => _AIAgentPageState();
}

class _AIAgentPageState extends State<AIAgentPage> {
  int? userId;
  Map<String, dynamic>? userData;
  bool alwaysListening = false;
  int selectedAvatar = 0;
  String selectedPersonality = 'Empathetic';
  String selectedVoice = 'Voice 1';

  @override
  void initState() {
    super.initState();
    loadUserIdAndData();
  }

  Future<void> loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('userId');
    final dbHelper = DBHelper();

    if (id == null) {
      print('No userId found in SharedPreferences');
      return;
    }

    final Map<String, dynamic>? data = await dbHelper.getUserById(id);
    if (data != null) {
      setState(() {
        userId = data['id'];
        userData = data;
        selectedAvatar = userData?["ai_avatar_id"] ?? 0;
        selectedPersonality = userData?["ai_personality"] ?? 'Empathetic';
        selectedVoice = userData?["ai_voice"] ?? 'Voice 1';
      });
    } else {
      print('User not found');
    }
  }

  Future<void> printUserInfo(int userId) async {
    final dbHelper = DBHelper();
    final userInfo = await dbHelper.getUserById(userId);

    if (userInfo != null) {
      print('User Info:');
      userInfo.forEach((key, value) {
        print('key: $key → value: $value → type: ${value.runtimeType}');
      });
    } else {
      print('No user found with id: $userId');
    }
  }

  final List<String> personalities = [
    'Empathetic',
    'Direct',
    'Balanced',
    'Mentally Focused',
  ];

  final List<String> voices = ['Voice 1', 'Voice 2', 'Voice 3', 'Voice 4'];

  @override
  Widget build(BuildContext context) {
    if (userData == null ||
        selectedPersonality == null ||
        selectedVoice == null ||
        selectedAvatar == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      body: ResponsiveLayout(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Arrow
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'AI Agent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Always Listening'),
                    Switch(
                      value: alwaysListening,
                      onChanged: (value) {
                        setState(() => alwaysListening = value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  'Appearance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedAvatar = index;
                      });
                      final dbHelper = DBHelper();
                      final prefs = await SharedPreferences.getInstance();
                      final id = userId ?? prefs.getInt('userId');
                      await dbHelper.updateUser(id!, {
                        'ai_avatar_id': selectedAvatar,
                      });
                      await printUserInfo(id!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedAvatar == index
                              ? Color(0xFF6B578C)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Transform.scale(
                          scale: _getScaleForIndex(index),
                          child: Image.asset(
                            'images/avatar${index + 1}.png',
                            fit: BoxFit.cover,
                            alignment: _getAlignmentForIndex(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Personality',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  "*Select each for more information",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: personalities.map((type) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: type,
                          groupValue: selectedPersonality,
                          onChanged: (value) async {
                            setState(() {
                              selectedPersonality = value!;
                            });
                            final dbHelper = DBHelper();
                            final prefs = await SharedPreferences.getInstance();
                            final id = userId ?? prefs.getInt('userId');
                            await dbHelper.updateUser(id!, {
                              'ai_personality': selectedPersonality,
                            });
                            await printUserInfo(id!);
                          },
                          activeColor: Color(0xFF6B578C),
                        ),
                        Text(type),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Voice',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 16,
                  children: voices.map((voice) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: voice,
                          groupValue: selectedVoice,
                          onChanged: (value) async {
                            setState(() => selectedVoice = value!);
                            final dbHelper = DBHelper();
                            final prefs = await SharedPreferences.getInstance();
                            final id = userId ?? prefs.getInt('userId');
                            await dbHelper.updateUser(id!, {
                              'ai_voice': selectedVoice,
                            });
                            await printUserInfo(id!);
                          },
                          activeColor: Color(0xFF6B578C),
                        ),
                        Text(voice),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Alignment _getAlignmentForIndex(int index) {
  switch (index) {
    case 3:
    case 4:
      return const Alignment(0, -0.9);
    case 5:
      return const Alignment(0, -0.2);
    case 6:
    case 7:
    case 8:
      return const Alignment(0, -0.7);
    default:
      return Alignment.center;
  }
}

double _getScaleForIndex(int index) {
  switch (index) {
    case 4:
      return 1.0;
    case 5:
      return 1.2;
    case 6:
      return 1.2;
    case 8:
      return 1.7;
    default:
      return 1.0;
  }
}

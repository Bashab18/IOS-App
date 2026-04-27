import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mhealthapp/screens/ActivityStats/activity_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';

import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/responsive_layout.dart';
import '../../exercise.dart';

class GoalSetting extends StatefulWidget {
  const GoalSetting({super.key});

  @override
  State<GoalSetting> createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSetting> {
  Map<String, bool> _goals = {};
  int? userId;
  final TextEditingController _customGoalController = TextEditingController();

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
        _goals = Map<String, bool>.from(jsonDecode(data['custom_goals']));
        userId = data['id'];
      });
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
    }
  }

  void _addCustomGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "New Custom Goal",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _customGoalController,
            decoration: InputDecoration(
              hintText: "Ex: Mobility, Learning Skills etc.",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepPurple),
                foregroundColor: Colors.black,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final goal = _customGoalController.text.trim();
                if (goal.isNotEmpty) {
                  setState(() {
                    _goals[goal] = true;
                  });
                  final dbHelper = DBHelper();
                  final jsonGoals = jsonEncode(_goals);
                  final prefs = await SharedPreferences.getInstance();
                  final id = userId ?? prefs.getInt('userId');
                  await dbHelper.updateUser(id!, {'custom_goals': jsonGoals});
                  await printUserInfo(id);
                }
                _customGoalController.clear();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_goals.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      /// ✅ WRAPPED IN RESPONSIVE LAYOUT (only structural change)
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
                'Goal Setting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),

                  ..._goals.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (val) async {
                          setState(() {
                            _goals[entry.key] = val!;
                          });
                          final dbHelper = DBHelper();
                          final jsonGoals = jsonEncode(_goals);
                          final prefs = await SharedPreferences.getInstance();
                          final id = userId ?? prefs.getInt('userId');
                          await dbHelper.updateUser(id!, {
                            'custom_goals': jsonGoals,
                          });
                          await printUserInfo(id);
                        },
                        activeColor: const Color(0xFF6B578C),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: _addCustomGoalDialog,
                    child: const Text(
                      '+ Add Custom Goal',
                      style: TextStyle(
                        color: Color(0xFF6B578C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

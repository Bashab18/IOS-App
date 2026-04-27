import 'package:mhealthapp/screens/ActivityStats/activity_page.dart';
import 'package:mhealthapp/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';

import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_app_bar.dart';
import 'gen_AI_workout_3.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class UserGoalsPopup extends StatefulWidget {
  final Map<String, dynamic> workoutData;

  const UserGoalsPopup({super.key, required this.workoutData});

  @override
  State<UserGoalsPopup> createState() => _UserGoalsPopupState();
}

class _UserGoalsPopupState extends State<UserGoalsPopup> {
  Map<String, bool> goals = {
    'Weight Loss': false,
    'Muscle Gain': false,
    'Cardiovascular Fitness': false,
    'Functional Fitness': false,
  };
  int? userId;
  final List<String> selectedGoals = [];
  final TextEditingController customGoalsController = TextEditingController();
  final TextEditingController healthConditionsController =
  TextEditingController();
  String? selectedFitnessLevel;
  String? healthConditions = '';

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
    } else {
      setState(() {
        userId = id;
      });
    }
    ;

    final Map<String, dynamic>? data = await dbHelper.getUserById(id);
    if (data != null) {
      print('Username: ${data['username']}');
      print('Email: ${data['email']}');
      setState(() {
        goals = Map<String, bool>.from(jsonDecode(data['custom_goals']));
        // Store or display in UI as needed
        healthConditions = data['health_conditions'];
        healthConditionsController.text = healthConditions ?? '';
      });
    } else {
      print('User not found');
      return;
    }
  }

  bool get hasSelectedGoal => goals.values.any((selected) => selected == true);

  bool get canProceed =>
      hasSelectedGoal && selectedFitnessLevel != null && userId != null;

  void _addCustomGoal() {
    final custom = customGoalsController.text.trim();
    if (custom.isNotEmpty && !goals.containsKey(custom)) {
      setState(() {
        goals[custom] = true;
        customGoalsController.clear();
      });
    }
  }

  Future<void> _onNext() async {
    if (!canProceed) return;

    final selectedGoalsList =
    goals.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final prehealthconditions = healthConditionsController.text.trim();

    // Parse health conditions from text input
    final healthConditionsList =
    healthConditionsController.text.trim().isEmpty
        ? <String>[]
        : healthConditionsController.text
        .split(',')
        .map((condition) => condition.trim())
        .where((condition) => condition.isNotEmpty)
        .toList();

    final dbHelper = DBHelper();

    await dbHelper.updateUser(userId!, {
      "custom_goals": jsonEncode(goals), // Map<String,bool>
      "health_conditions": prehealthconditions,
    });

    final updatedData = Map<String, dynamic>.from(widget.workoutData);
    updatedData['goals'] = selectedGoalsList;
    updatedData['custom_goals'] =
    customGoalsController.text.trim().isEmpty
        ? null
        : customGoalsController.text.trim();
    updatedData['health_conditions'] = healthConditionsList;
    updatedData['fitness_level'] = selectedFitnessLevel!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdditionalCommentsPopup(workoutData: updatedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "mHealth"),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Exercise Goals
              const Text(
                'Exercise Goal(s):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 4,
                  childAspectRatio: 3.5,
                ),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals.keys.elementAt(index);
                  return Row(
                    children: [
                      Checkbox(
                        value: goals[goal],
                        onChanged: (value) {
                          setState(() {
                            goals[goal] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF6B578C),
                      ),
                      Expanded(
                        child: Text(goal, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Add custom goal
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customGoalsController,
                      decoration: InputDecoration(
                        hintText: 'Add custom goal...',
                        hintStyle: const TextStyle(color: Color(0xFF6B578C)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF6B578C)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF6B578C),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addCustomGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B578C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(60, 48),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Health Conditions
              const Text(
                'Preexisting Health Condition(s)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add any preexisting health conditions not already recorded in app.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                '(e.g., arthritis, heart conditions, joint pain, past injuries, etc.)',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: healthConditionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter health conditions separated by commas...',
                  hintStyle: const TextStyle(color: Color(0xFF6B578C)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF6B578C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF6B578C),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 24),

              // Fitness Level
              const Text(
                'Current Fitness Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              ...['Beginner', 'Intermediate', 'Expert'].map((level) {
                return RadioListTile<String>(
                  title: Text(level),
                  value: level,
                  groupValue: selectedFitnessLevel,
                  activeColor: const Color(0xFF6B578C),
                  onChanged: (value) {
                    setState(() {
                      selectedFitnessLevel = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed ? _onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    canProceed ? const Color(0xFF6B578C) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        )
    );
  }
  @override
  void dispose() {
    customGoalsController.dispose();
    healthConditionsController.dispose();
    super.dispose();
  }
}




import 'package:flutter/material.dart';
import 'package:mhealthapp/screens/home_page.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/responsive_layout.dart';
import 'gen_AI_workout_2.dart';

class GenerateAIRoutinePopup extends StatefulWidget {
  final int userId;

  const GenerateAIRoutinePopup({
  super.key,
  required this.userId,
  });

  @override
  State<GenerateAIRoutinePopup> createState() => _GenerateAIRoutinePopupState();
}

class _GenerateAIRoutinePopupState extends State<GenerateAIRoutinePopup> {
  final List<String> selectedAreas = [];
  final TextEditingController durationController = TextEditingController();
  String? selectedIntensity;

  final Map<String, bool> targetAreas = {
    'Arms': false,
    'Back': false,
    'Legs': false,
    'Shoulders': false,
    'Abdomen': false,
    'Full Body': false,
  };

  bool get hasSelectedTargetArea => targetAreas.values.any((selected) => selected);
  bool get canProceed =>
      hasSelectedTargetArea &&
          durationController.text.trim().isNotEmpty &&
          selectedIntensity != null;

  void _onNext() {
    if (!canProceed) return;

    final selectedTargets = targetAreas.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final workoutData = {
      'user_id': widget.userId,
      'target_areas': selectedTargets,
      'duration_minutes': int.tryParse(durationController.text.trim()),
      'intensity': selectedIntensity!,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserGoalsPopup(workoutData: workoutData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Global AppBar
      appBar: const CustomAppBar(title: "mHealth"),

      // ✅ Responsive Layout Wrapper
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Generate AI Workout Routine',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create a personalized workout routine tailored to your specific needs and goals using AI.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Target Areas
              const Text(
                'Target Area(s) of Body:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 4,
                  childAspectRatio: 4,
                ),
                itemCount: targetAreas.length,
                itemBuilder: (context, index) {
                  final area = targetAreas.keys.elementAt(index);
                  return Row(
                    children: [
                      Checkbox(
                        value: targetAreas[area],
                        onChanged: (value) {
                          setState(() {
                            targetAreas[area] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF6B578C),
                      ),
                      Expanded(
                        child: Text(
                          area,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Workout Duration
              const Text(
                'Workout Duration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter duration in minutes',
                  hintStyle: const TextStyle(color: Color(0xFF6B578C)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF6B578C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF6B578C), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '*Enter number in minutes',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // Exercise Intensity
              const Text(
                'Exercise Intensity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              ...['Light', 'Moderate', 'Intense'].map((intensity) {
                return RadioListTile<String>(
                  title: Text(intensity),
                  value: intensity,
                  groupValue: selectedIntensity,
                  activeColor: const Color(0xFF6B578C),
                  onChanged: (value) {
                    setState(() {
                      selectedIntensity = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),

              const SizedBox(height: 24),

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
        ),
      ),

      // ✅ Unified BottomNavBar
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }
}

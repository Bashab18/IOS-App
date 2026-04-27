import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/models/ai_routine_request.dart';
import 'package:mhealthapp/screens/home_page.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/responsive_layout.dart';
import 'loading_plan_popup.dart';

class AdditionalCommentsPopup extends StatefulWidget {
  final Map<String, dynamic> workoutData;

  const AdditionalCommentsPopup({
  super.key,
  required this.workoutData,
  });

  @override
  State<AdditionalCommentsPopup> createState() => _AdditionalCommentsPopupState();
}

class _AdditionalCommentsPopupState extends State<AdditionalCommentsPopup> {
  final TextEditingController _commentsController = TextEditingController();

  void _onCreateRoutine() async {
    try {
      final request = AIRoutineRequest(
        userId: widget.workoutData['user_id'],
        targetAreas: List<String>.from(widget.workoutData['target_areas']),
        durationMinutes: widget.workoutData['duration_minutes'],
        intensity: widget.workoutData['intensity'],
        goals: List<String>.from(widget.workoutData['goals']),
        customGoals: widget.workoutData['custom_goals'],
        healthConditions: List<String>.from(widget.workoutData['health_conditions'] ?? []),
        fitnessLevel: widget.workoutData['fitness_level'],
        additionalComments: _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      );

      final dbHelper = DBHelper();
      await dbHelper.insertAIRoutineRequest(request);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(
          userId: widget.workoutData['user_id'],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to create AI workout request: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Global AppBar
      appBar: const CustomAppBar(title: "mHealth"),

      // ✅ Responsive layout wrapper
      body: ResponsiveLayout(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Additional Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Feel free to include below anything else we should know to best tailor your routine!',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // ✅ Summary section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6B578C).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF6B578C).withOpacity(0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Routine Summary:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text('Target Areas: ${(widget.workoutData['target_areas'] as List).join(', ')}'),
                    Text('Duration: ${widget.workoutData['duration_minutes']} minutes'),
                    Text('Intensity: ${widget.workoutData['intensity']}'),
                    Text('Goals: ${(widget.workoutData['goals'] as List).join(', ')}'),
                    Text('Fitness Level: ${widget.workoutData['fitness_level']}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Comments Field
              const Text(
                'Additional Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  TextField(
                    controller: _commentsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter any additional information here...',
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
                  const Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 8),
                    child: Icon(Icons.mic, color: Color(0xFF6B578C), size: 20),
                  ),
                ],
              ),

              const Spacer(),

              // ✅ Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onCreateRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B578C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    'Generate AI Routine',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ✅ Unified Bottom Nav
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}

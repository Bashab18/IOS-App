import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/models/log_routine.dart';
import '../../../widgets/responsive_layout.dart';

class CaloriesBurnedPopup extends StatefulWidget {
  final Map<String, dynamic> workoutData;

  const CaloriesBurnedPopup({super.key, required this.workoutData});

  @override
  State<CaloriesBurnedPopup> createState() => _CaloriesBurnedPopupState();
}

class _CaloriesBurnedPopupState extends State<CaloriesBurnedPopup> {
  final TextEditingController caloriesController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.55;

    return Center(
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ResponsiveLayout(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: dialogHeight),
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Calories Burned',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Enter the total calories burned for this workout.",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // Calories Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter a value',
                            hintStyle:
                            const TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF6B578C)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF6B578C), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'cal',
                        style: TextStyle(
                          color: Color(0xFF6B578C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Note: This field is optional but recommended to enhance your fitness insights. "
                        "If you have a smartwatch or tracker, use its data for better accuracy.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B578C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : const Text(
                        "Save Workout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveWorkout() async {
    setState(() => _isLoading = true);

    try {
      // Parse calories if entered
      double? calories;
      if (caloriesController.text.trim().isNotEmpty) {
        calories = double.tryParse(caloriesController.text.trim());
        if (calories == null || calories < 0) {
          _showErrorMessage('Please enter a valid number for calories');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Create the workout log
      final workoutLog = WorkoutLog(
        workoutRoutineFactId: widget.workoutData['workoutRoutineFactId'],
        userDimId: widget.workoutData['userId'],
        logDate: widget.workoutData['date'],
        logDuration: widget.workoutData['durationMinutes'] ?? 0,
        routineName: widget.workoutData['routineName'],
        caloriesBurned: calories,
      );

      // Save to database
      await _dbHelper.insertWorkoutLog(workoutLog);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorMessage('Failed to save workout. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    caloriesController.dispose();
    super.dispose();
  }
}

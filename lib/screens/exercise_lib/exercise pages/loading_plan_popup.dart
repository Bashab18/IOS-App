import 'package:flutter/material.dart';
import 'dart:async';
import 'exercise_routine_ai.dart';

class LoadingDialog extends StatefulWidget {
  final int userId;

  const LoadingDialog({super.key, required this.userId});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.05;
      });

      if (_progress >= 1.0) {
        _timer?.cancel();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExerciseRoutinePage()),
        );
      }
    });
  }

  void _cancelGeneration() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.85;

    return Center(
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF6B578C),
                  size: 48,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Generating Your Workout Plan...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Please wait while we personalize your routine using AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 24),

                // Progress Bar
                LinearProgressIndicator(
                  value: _progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF6B578C),
                ),
                const SizedBox(height: 12),

                // Percentage Text
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),

                // Cancel Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _cancelGeneration,
                    icon: const Icon(Icons.close, color: Color(0xFF6B578C)),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF6B578C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

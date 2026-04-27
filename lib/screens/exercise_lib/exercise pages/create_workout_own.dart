import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/models/routine_exercise.dart';
import 'package:mhealthapp/models/workout_routine.dart';
import 'package:mhealthapp/screens/ActivityStats/activity_page.dart';
import 'package:mhealthapp/screens/exercise_lib/exercise_lib.dart';
import 'package:mhealthapp/screens/home_page.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_app_bar.dart';
import 'create_workout_own_popup.dart';
import 'package:flutter/material.dart';

class BuildRoutinePage extends StatefulWidget {
  final int userId;

  const BuildRoutinePage({super.key, required this.userId});

  @override
  State<BuildRoutinePage> createState() => _BuildRoutinePageState();
}

class _BuildRoutinePageState extends State<BuildRoutinePage> {
  final TextEditingController routineNameController = TextEditingController();
  final List<RoutineExercise> selectedExercises = [];
  final DBHelper dbHelper = DBHelper();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Build Workout Routine"),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                const Text(
                  'Build Your Own Workout Routine',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose exercises from your Exercise Library to build your personalized workout routine!',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Routine name input
                TextField(
                  controller: routineNameController,
                  decoration: InputDecoration(
                    hintText: 'Name your routine',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B578C),
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF6B578C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF6B578C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),

                // Add exercise buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddExerciseDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Exercise'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B578C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                const SizedBox(height: 16),

                // Selected exercises section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedExercises.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Exercises (${selectedExercises.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _clearAllExercises,
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Clear All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: selectedExercises.length,
                            itemBuilder: (context, index) {
                              final exercise = selectedExercises[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF6B578C),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    exercise.exerciseName ?? 'Unknown Exercise',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target: ${exercise.targetArea ?? 'N/A'}',
                                      ),
                                      Text(
                                        '${exercise.sets} sets × ${exercise.repetitions} reps'
                                            '${exercise.weight > 0 ? ' × ${exercise.weight} ${exercise.weightUnit}' : ''}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6B578C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // IconButton(
                                      //   icon: const Icon(Icons.edit, color: Color(0xFF6B578C)),
                                      //   onPressed: () => _editExercise(index),
                                      //   tooltip: 'Edit Exercise',
                                      // ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _removeExercise(index),
                                        tooltip: 'Remove Exercise',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else
                        const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No exercises added yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap "Add Exercise" to get started!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Save button (only show if there are exercises)
                if (selectedExercises.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _saveRoutine,
                      icon:
                      isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.save),
                      label: Text(
                        isLoading ? 'Saving Routine...' : 'Save Routine',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B578C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Saving routine...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar:
      const BottomNavBar(currentIndex: 3), // ✅ Unified Bottom Nav Bar
    );
  }

  // Show the Add Exercise Dialog
  Future<void> _showAddExerciseDialog() async {
    try {
      final result = await showDialog<RoutineExercise>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return AddExercisePopup(
            userId: widget.userId,
            onExerciseAdded: (exercise) {
              print('📝 Exercise added in popup: ${exercise.exerciseName}');
              Navigator.of(dialogContext).pop(exercise);
            },
          );
        },
      );

      if (result != null) {
        print('🎯 Adding exercise to routine...');
        setState(() {
          selectedExercises.add(result);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Added "${result.exerciseName}" to routine'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Edit an existing exercise in the routine
  // void _editExercise(int index) {
  //   final exercise = selectedExercises[index];
  //   showDialog(
  //   );
  // }

  // Remove an exercise from the routine
  void _removeExercise(int index) {
    final exerciseName = selectedExercises[index].exerciseName;

    setState(() {
      selectedExercises.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Removed "$exerciseName" from routine'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Clear all exercises
  void _clearAllExercises() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Clear All Exercises'),
        content: Text(
          'Are you sure you want to remove all ${selectedExercises.length} exercises from this routine?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedExercises.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All exercises cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // Save the complete routine to database
  Future<void> _saveRoutine() async {
    // Validation
    if (routineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a routine name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please add at least one exercise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create the workout routine
      final routine = WorkoutRoutine(
        userDimId: widget.userId,
        workoutRoutineName: routineNameController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );

      // Save the complete routine with all exercises
      final routineId = await dbHelper.saveCompleteRoutine(
        routine,
        selectedExercises,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Routine "${routine.workoutRoutineName}" saved successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to previous screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseLibraryPage(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save routine: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Always reset loading state
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    routineNameController.dispose();
    super.dispose();
  }
}

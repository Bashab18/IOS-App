import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mhealthapp/db_helper.dart';
import '../../../widgets/responsive_layout.dart';
import 'log_workout_popup_2.dart';

class LogWorkoutPopup extends StatefulWidget {
  final int userId;

  const LogWorkoutPopup({
  super.key,
  required this.userId,
  });

  @override
  State<LogWorkoutPopup> createState() => _LogWorkoutPopupState();
}

class _LogWorkoutPopupState extends State<LogWorkoutPopup> {
  final TextEditingController durationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> workoutRoutines = [];
  int? selectedRoutineId;
  String? selectedRoutineName;
  bool _isLoadingRoutines = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutRoutines();
  }

  Future<void> _loadWorkoutRoutines() async {
    try {
      final routines = await DBHelper().getRoutinesForDropdown(widget.userId);
      setState(() {
        workoutRoutines = routines;
        _isLoadingRoutines = false;
      });
    } catch (e) {
      setState(() => _isLoadingRoutines = false);
    }
  }

  bool _isValidSelection() {
    if (selectedRoutineId == null) return false;
    return workoutRoutines
        .any((r) => r['workout_routine_fact_id'] == selectedRoutineId);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.65;

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
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    "Log Workout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Routine selection
                  const Text(
                    "Select Routine",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingRoutines
                      ? const SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B578C),
                      ),
                    ),
                  )
                      : DropdownButtonFormField<int>(
                    value: _isValidSelection()
                        ? selectedRoutineId
                        : null,
                    decoration: InputDecoration(
                      hintText: "Choose a workout routine",
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
                    items: workoutRoutines.map((routine) {
                      return DropdownMenuItem<int>(
                        value: routine['workout_routine_fact_id'],
                        child: Text(
                          routine['workout_routine_name'] ??
                              'Unnamed Routine',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRoutineId = value;
                        if (value != null) {
                          final routine = workoutRoutines.firstWhere(
                                (r) =>
                            r['workout_routine_fact_id'] == value,
                            orElse: () => {},
                          );
                          selectedRoutineName =
                              routine['workout_routine_name'] ??
                                  'Unnamed Routine';
                        } else {
                          selectedRoutineName = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  const Text(
                    "Date",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: const Color(0xFF6B578C)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MM/dd/yyyy')
                                .format(selectedDate),
                          ),
                          const Icon(Icons.calendar_today,
                              color: Color(0xFF6B578C)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration input
                  const Text(
                    "Duration (minutes)",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: "min",
                      hintText: "Enter workout duration",
                      hintStyle:
                      const TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Color(0xFF6B578C)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF6B578C), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _validateAndProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B578C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        "Next",
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

  void _validateAndProceed() {
    if (selectedRoutineId == null || selectedRoutineName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a workout routine'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? duration;
    if (durationController.text.trim().isNotEmpty) {
      duration = int.tryParse(durationController.text.trim());
      if (duration == null || duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid duration in minutes'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final workoutData = {
      'userId': widget.userId,
      'workoutRoutineFactId': selectedRoutineId!,
      'routineName': selectedRoutineName!,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'durationMinutes': duration,
    };

    showDialog(
      context: context,
      builder: (_) => CaloriesBurnedPopup(workoutData: workoutData),
    ).then((result) {
      if (result == true) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:mhealthapp/models/custom_exercise.dart';
import 'create_custom_exercise_popup3.dart';

// ✅ Added shared responsive layout
import '../../../widgets/responsive_layout.dart';

class CreateCustomExercisePopup2 extends StatefulWidget {
  final CustomExercise exercise;
  final Function(CustomExercise) onComplete;

  const CreateCustomExercisePopup2({
  super.key,
  required this.exercise,
  required this.onComplete,
  });

  @override
  State<CreateCustomExercisePopup2> createState() =>
      _CreateCustomExercisePopup2State();
}

class _CreateCustomExercisePopup2State
    extends State<CreateCustomExercisePopup2> {
  final List<String> equipment = [];

  Future<void> _addEquipment() async {
    final controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 32,
          vertical: isSmallScreen ? 60 : 80,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

        // ✅ Added ResponsiveLayout wrapper for dialog content
        child: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title + close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Equipment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child:
                        const Icon(Icons.close, color: Colors.black, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Input field
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Enter equipment name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            Navigator.pop(context, controller.text.trim()),
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => equipment.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 32,
        vertical: isSmallScreen ? 60 : 80,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

      // ✅ Responsive wrapper for main popup
      child: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.black, size: 24),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  "Exercise Equipment",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
                ),
                const SizedBox(height: 10),

                // List of added equipment
                ...equipment.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "• $e",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      color: Colors.black87,
                    ),
                  ),
                )),

                const SizedBox(height: 8),

                // + Add Equipment link
                GestureDetector(
                  onTap: _addEquipment,
                  child: const Text(
                    "+ Add Equipment",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Next button
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 40 : 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      final updated = widget.exercise.copyWith(
                        equipment: equipment.join(', '),
                      );
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => CreateCustomExercisePopup3(
                          exercise: updated,
                          onComplete: widget.onComplete,
                        ),
                      );
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
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

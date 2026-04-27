import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/models/custom_exercise.dart';
import 'package:mhealthapp/models/exercise_library.dart';
import 'package:mhealthapp/models/routine_exercise.dart';
import '../../../widgets/responsive_layout.dart'; // ✅ added responsive layout

class AddExercisePopup extends StatefulWidget {
  final Function(RoutineExercise) onExerciseAdded;
  final int userId;

  const AddExercisePopup({
  super.key,
  required this.onExerciseAdded,
  required this.userId,
  });

  @override
  State<AddExercisePopup> createState() => _AddExercisePopupState();
}

class _AddExercisePopupState extends State<AddExercisePopup> {
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String selectedUnit = 'lbs';
  final List<String> unitOptions = ['lbs', 'kg'];

  List<ExerciseLibrary> libraryExercises = [];
  List<CustomExercise> customExercises = [];
  List<dynamic> allExercises = [];
  dynamic selectedExercise;

  bool isLoadingExercises = true;
  String? loadingError;

  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      setState(() {
        isLoadingExercises = true;
        loadingError = null;
      });

      final futures = await Future.wait([
        dbHelper.getAllLibraryExercises(),
        dbHelper.getCustomExercisesByUser(widget.userId),
      ]);

      libraryExercises = futures[0] as List<ExerciseLibrary>;
      customExercises = futures[1] as List<CustomExercise>;

      if (mounted) {
        setState(() {
          allExercises = [...libraryExercises, ...customExercises];
          if (allExercises.isNotEmpty) {
            selectedExercise = allExercises.first;
          }
          isLoadingExercises = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingExercises = false;
          loadingError = 'Failed to load exercises: $e';
        });
      }
    }
  }

  String _getExerciseName(dynamic exercise) {
    if (exercise == null) return 'Unknown';
    if (exercise is ExerciseLibrary) return exercise.exerciseName ?? 'Unnamed Exercise';
    if (exercise is CustomExercise) return exercise.exerciseName ?? 'Unnamed Exercise';
    return 'Unknown';
  }

  String _getExerciseTargetArea(dynamic exercise) {
    if (exercise == null) return '';
    if (exercise is ExerciseLibrary) return exercise.targetArea ?? '';
    if (exercise is CustomExercise) return exercise.targetArea.join(', ');
    return '';
  }

  bool _isLibraryExercise(dynamic exercise) => exercise is ExerciseLibrary;
  int _getExerciseId(dynamic exercise) => exercise?.id ?? 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400.0;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Exercise',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Exercise Name
                const Text(
                  'Exercise Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (isLoadingExercises)
                  _loadingBox()
                else if (loadingError != null)
                  _errorBox()
                else if (allExercises.isNotEmpty)
                    _buildExerciseDropdown()
                  else
                    _emptyBox(),

                const SizedBox(height: 16),

                // Reps
                _buildTextField(
                  'Number of Repetitions',
                  repsController,
                  'Enter repetitions (e.g., 10)',
                ),
                const SizedBox(height: 16),

                // Sets
                _buildTextField(
                  'Number of Sets',
                  setsController,
                  'Enter sets (e.g., 3)',
                ),
                const SizedBox(height: 16),

                // Weight
                _buildWeightSection(),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isLoadingExercises || allExercises.isEmpty)
                        ? null
                        : _saveExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B578C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Add Exercise',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _loadingBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: _boxBorder(const Color(0xFF6B578C)),
    child: const Row(
      children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: 12),
        Text('Loading exercises...'),
      ],
    ),
  );

  Widget _errorBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: _boxBorder(Colors.red),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Error loading exercises', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        Text(loadingError ?? '', style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _loadExercises, child: const Text('Retry')),
      ],
    ),
  );

  Widget _emptyBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: _boxBorder(Colors.orange),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No exercises available', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Please create some exercises first in your Exercise Library.'),
      ],
    ),
  );

  BoxDecoration _boxBorder(Color color) => BoxDecoration(
    border: Border.all(color: color),
    borderRadius: BorderRadius.circular(8),
  );

  Widget _buildExerciseDropdown() {
    final dropdownItems = allExercises.map((exercise) {
      final name = _getExerciseName(exercise);
      final target = _getExerciseTargetArea(exercise);
      final isCustom = !_isLibraryExercise(exercise);
      return DropdownMenuItem(
        value: exercise,
        child: Row(
          children: [
            Expanded(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14))),
            const SizedBox(width: 8),
            Text(
              '($target${isCustom ? ' - Custom' : ''})',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }).toList();

    return DropdownButtonFormField<dynamic>(
      value: selectedExercise,
      items: dropdownItems,
      onChanged: (value) => setState(() => selectedExercise = value),
      decoration: InputDecoration(
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
      isExpanded: true,
      isDense: true,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }

  Widget _buildWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weight (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter weight (e.g., 50)',
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
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF6B578C)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedUnit,
                underline: const SizedBox(),
                items: unitOptions
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (value) => setState(() => selectedUnit = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveExercise() {
    final reps = int.tryParse(repsController.text.trim()) ?? 0;
    final sets = int.tryParse(setsController.text.trim()) ?? 0;
    final weight = int.tryParse(weightController.text.trim()) ?? 0;

    if (selectedExercise == null) return _showError('Please select an exercise');
    if (reps <= 0) return _showError('Enter valid repetitions');
    if (sets <= 0) return _showError('Enter valid sets');

    final routineExercise = RoutineExercise(
      workoutRoutineFactId: 0,
      exerciseLibraryDimId:
      _isLibraryExercise(selectedExercise) ? _getExerciseId(selectedExercise) : null,
      userExerciseDimId:
      !_isLibraryExercise(selectedExercise) ? _getExerciseId(selectedExercise) : null,
      repetitions: reps,
      sets: sets,
      weight: weight,
      weightUnit: selectedUnit,
      exerciseName: _getExerciseName(selectedExercise),
      targetArea: _getExerciseTargetArea(selectedExercise),
    );

    widget.onExerciseAdded(routineExercise);
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    repsController.dispose();
    setsController.dispose();
    weightController.dispose();
    super.dispose();
  }
}

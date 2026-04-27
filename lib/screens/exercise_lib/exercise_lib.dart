import 'package:flutter/material.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:mhealthapp/main.dart';
import 'package:mhealthapp/models/custom_exercise.dart';
import 'package:mhealthapp/models/workout_routine.dart';
import '../Settings/settings_1.dart';
import '../challenges.dart';
import '/screens/home_page.dart';
import 'exercise pages/create_custom_exercise.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '/health/exercise_category_page.dart';
import '/health/exercise_detail_page.dart';
import '/health/exercise_loader.dart';
import '/models/exercise_model.dart';

class ExerciseLibraryPage extends StatefulWidget {
  final int userId;

  const ExerciseLibraryPage({super.key, required this.userId});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _searchController = TextEditingController();

  List<WorkoutRoutine> _userRoutines = [];
  List<CustomExercise> _userExercises = [];
  bool _isLoading = true;

  final Map<String, String> _exerciseRoutes = {
    "arms": "/arms",
    "legs": "/legs",
    "shoulders": "/shoulders",
    "back": "/back",
    "core": "/core",
    "chest": "/chest",
    "stretches": "/stretches",
    "yoga": "/yoga",
  };

  Future<void> _searchExercise(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final q = controller.text.trim().toLowerCase();
    if (q.isEmpty) return;

    // 1) Load exercises (cached after first call)
    final List<Exercise> all = await ExerciseLoader.load();

    // 2) Match by name + categories (case-insensitive, null-safe)
    bool _contains(String? s) => (s ?? '').toLowerCase().contains(q);

    final List<Exercise> matches =
    all.where((e) {
      return _contains(e.name) ||
          _contains(e.category1) ||
          _contains(e.category2) ||
          _contains(e.category3);
    }).toList()
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3) Navigate: one match -> open; many matches -> let user pick
    if (matches.length == 1) {
      _goToExercise(context, matches.first);
      return;
    }

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
        child: ListView(
          children: [
            for (final e in matches)
              ListTile(
                title: Text(e.name ?? '(unnamed)'),
                subtitle: Text(
                  [e.category1, e.category2, e.category3]
                      .whereType<String>()
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                ),
                onTap: () {
                  Navigator.pop(context); // close sheet
                  _goToExercise(context, e); // open detail
                },
              ),
          ],
        ),
      ),
    );
  }

  void _goToExercise(BuildContext context, Exercise e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseDetailPage(exercise: e)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final routines = await _dbHelper.getWorkoutRoutinesByUser(widget.userId);
      final exercises = await _dbHelper.getCustomExercisesByUser(widget.userId);
      setState(() {
        _userRoutines = routines;
        _userExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"), // ✅ Unified App Bar
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
      ), // ✅ Unified Bottom Nav Bar
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed:
                      () => Navigator.pop(context, _searchController),
                ),
                // 🔍 Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search exercises...",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.deepPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.deepPurple,
                      ),
                      onPressed:
                          () => _searchExercise(
                        context,
                        _searchController,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted:
                      (_) =>
                      _searchExercise(context, _searchController),
                ),
                const SizedBox(height: 20),

                sectionTitle("Workout Routines"),
                const SizedBox(height: 8),
                _buildRoutineGroup(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                    _userRoutines.isNotEmpty
                        ? _showAllRoutines
                        : null,
                    child: Text(
                      "View all >",
                      style: TextStyle(
                        color:
                        _userRoutines.isNotEmpty
                            ? Colors.deepPurple
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                sectionTitle("Your Exercises"),
                const SizedBox(height: 8),

                // ➕ Create Custom Exercise Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CreateCustomExercisePage(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Create Custom Exercise"),
                  ),
                ),

                const SizedBox(height: 12),
                _buildCustomExercisesSection(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                    _userExercises.isNotEmpty
                        ? _showAllCustomExercises
                        : null,
                    child: Text(
                      "View all >",
                      style: TextStyle(
                        color:
                        _userExercises.isNotEmpty
                            ? Colors.deepPurple
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                sectionTitle("Pre-Defined Exercises"),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2,
                  children: [
                    _buildExerciseButton(
                      "Arms",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Arms',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Legs",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Legs',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Shoulders",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Shoulders',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Back",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Back',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Core",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Core',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Chest",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Chest',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Stretches",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Stretches',
                          ),
                        ),
                      ),
                    ),
                    _buildExerciseButton(
                      "Yoga",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ExerciseCategoryPage(
                            category: 'Yoga',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- Helper UI Sections -----------------------
  Widget sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  Widget _buildRoutineGroup() {
    if (_userRoutines.isEmpty) {
      return _emptyState(
        "No workout routines yet. Create your first routine!",
        Icons.fitness_center,
      );
    }

    final displayRoutines = _userRoutines.take(3).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children:
        displayRoutines.asMap().entries.map((entry) {
          final index = entry.key;
          final routine = entry.value;
          return Column(
            children: [
              if (index > 0) const Divider(height: 1, color: Colors.white),
              _buildInnerRoutineTile(routine),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ],
    ),
  );

  Widget _buildInnerRoutineTile(WorkoutRoutine routine) {
    return InkWell(
      onTap: () => _viewRoutineDetails(routine),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.workoutRoutineName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created ${_formatDate(routine.createdAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomExercisesSection() {
    if (_userExercises.isEmpty) {
      return _emptyState(
        "No custom exercises yet. Create your own exercises!",
        Icons.add_circle_outline,
      );
    }

    final displayExercises = _userExercises.take(3).toList();
    return Column(
      children:
      displayExercises
          .map(
            (exercise) => _buildExerciseTile(
          exercise.exerciseName,
          exercise.targetArea.join('; '),
          exercise,
        ),
      )
          .toList(),
    );
  }

  Widget _buildExerciseTile(
      String name,
      String category, [
        CustomExercise? exercise,
      ]) {
    return InkWell(
      onTap: exercise != null ? () => _viewExerciseDetails(exercise) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  // --------------------- Helpers ---------------------
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  void _viewRoutineDetails(WorkoutRoutine routine) =>
      print('View routine: ${routine.workoutRoutineName}');

  void _viewExerciseDetails(CustomExercise exercise) =>
      print('View exercise: ${exercise.exerciseName}');

  void _showAllRoutines() =>
      print('Show all routines for user: ${widget.userId}');

  void _showAllCustomExercises() =>
      print('Show all custom exercises for user: ${widget.userId}');
}

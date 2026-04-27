import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../health/exercise_loader.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'exercise_detail_page.dart';

class ExerciseCategoryPage extends StatefulWidget {
  final String category;
  const ExerciseCategoryPage({required this.category, Key? key}) : super(key: key);

  @override
  State<ExerciseCategoryPage> createState() => _ExerciseCategoryPageState();
}

class _ExerciseCategoryPageState extends State<ExerciseCategoryPage> {
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('⚙️ [ExerciseCategoryPage] Starting _loadData for category: ${widget.category}');
    try {
      final all = await ExerciseLoader.load();
      print('📦 [ExerciseCategoryPage] Total exercises loaded: ${all.length}');

      String norm(String s) => s.toLowerCase().trim();
      final target = norm(widget.category);

      // ✅ Match category1 OR category2 OR category3
      final filtered = all.where((e) {
        final c1 = norm(e.category1);
        final c2 = norm(e.category2);
        final c3 = norm(e.category3);
        return c1 == target || c2 == target || c3 == target;
      }).toList();

      // ✅ Optional alphabetical sort
      filtered.sort((a, b) => a.name.compareTo(b.name));

      print('🎯 [ExerciseCategoryPage] Found ${filtered.length} exercises for ${widget.category}');
      setState(() => _exercises = filtered);

      // Optional sanity check for category counts
      final catCounts = <String, int>{};
      for (final e in all) {
        final c = e.category1.toLowerCase().trim();
        catCounts[c] = (catCounts[c] ?? 0) + 1;
      }
      print('📊 Category1 counts: $catCounts');

    } catch (e, s) {
      print('❌ [ExerciseCategoryPage] Error while loading data: $e');
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🖼 [ExerciseCategoryPage] Building UI with ${_exercises.length} exercises');

    return Scaffold(
      appBar: const CustomAppBar(title: "mHealth"), // ✅ Unified App Bar
      bottomNavigationBar:
      const BottomNavBar(currentIndex: 2), // ✅ Unified Bottom Nav Bar
      body: _exercises.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final ex = _exercises[index];
          print('🧱 [ExerciseCategoryPage] Building grid item: ${ex.name}');
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              print('➡️ [ExerciseCategoryPage] Navigating to ${ex.name}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailPage(exercise: ex),
                ),
              );
            },
            child: Center(
              child: Text(
                ex.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

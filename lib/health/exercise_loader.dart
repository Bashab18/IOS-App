import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/exercise_model.dart';

class ExerciseLoader {
  static List<Exercise>? _cache;

  static Future<List<Exercise>> load() async {
    if (_cache != null) {
      print('✅ [ExerciseLoader] Using cached: ${_cache!.length}');
      return _cache!;
    }

    print('🚀 [ExerciseLoader] Loading CSV…');
    final csvString = await rootBundle.loadString('images/merged_exercises.csv');
    print('📄 [ExerciseLoader] Bytes: ${csvString.length}');

    // Parse CSV
    final rows = const CsvToListConverter(
      eol: '\n',
      fieldDelimiter: ',',
      textDelimiter: '"',
      shouldParseNumbers: false,
    ).convert(csvString);

    if (rows.isEmpty) {
      throw StateError('CSV has no rows');
    }

    // Header row → map header -> index (case exact as in CSV)
    final headers = rows.first.map((e) => (e ?? '').toString().trim()).toList();
    final headerToIndex = <String, int>{
      for (int i = 0; i < headers.length; i++) headers[i]: i,
    };

    // Required headers (adjust names if your CSV differs)
    const required = [
      'Name','Video Link','Category 1','Category 2','Category 3',
      'Audience','Accessory 1','Accessory 2','Accessory 3','What to Do','Repetitions',
      'Muscles Involved',
      'Heuristic Level',
      'ACSM Level',
    ];
    for (final h in required) {
      if (!headerToIndex.containsKey(h)) {
        throw StateError('Missing CSV column: "$h". Found: $headers');
      }
    }

    // Build Exercise list from header-aware maps
    final list = <Exercise>[];
    for (int r = 1; r < rows.length; r++) {
      final row = rows[r];
      // Guard for short/blank rows
      if (row.isEmpty) continue;

      String cell(String col) {
        final idx = headerToIndex[col]!;
        if (idx >= row.length) return '';
        final v = row[idx];
        return (v ?? '').toString();
      }

      final m = <String, String>{
        for (final h in required) h: cell(h),
      };

      try {
        list.add(Exercise.fromMap(m));
      } catch (err) {
        print('⚠️ [ExerciseLoader] Row $r parse error: $err\nRow: $row');
      }
    }

    print('✅ [ExerciseLoader] Loaded ${list.length} exercises');
    // Optional: print first few categories to verify
    for (final e in list.take(5)) {
      print('🔎 ex="${e.name}" cat1="${e.category1}"');
    }

    _cache = list;
    return _cache!;
  }
}

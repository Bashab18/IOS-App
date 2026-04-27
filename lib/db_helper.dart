import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:mhealthapp/health/health_package.dart';
import 'package:mhealthapp/models/exercise_library.dart';
import 'models/custom_exercise.dart';
import 'models/workout_routine.dart';
import 'models/routine_exercise.dart';
import 'models/ai_routine_request.dart';
import 'models/log_routine.dart';
import 'package:uuid/uuid.dart';

class ActivityStats {
  final int steps;
  final int calories;
  final int avgBpm;
  final int maxBpm;
  final int exerciseMinutes;
  final double sedentaryHours;
  final double activeHours;
  final double sleepHours;
  final double distance;
  final int sleepDeepMinutes;
  final int sleepLightMinutes;
  final int sleepRemMinutes;

  ActivityStats({
    required this.steps,
    required this.calories,
    required this.avgBpm,
    required this.maxBpm,
    required this.exerciseMinutes,
    required this.sedentaryHours,
    required this.activeHours,
    required this.sleepHours,
    required this.distance,
    required this.sleepDeepMinutes,
    required this.sleepLightMinutes,
    required this.sleepRemMinutes,
  });
}
enum Metric { steps, calories }

DateTime _mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

class DailyPoint {
  final DateTime date;
  final double value;
  DailyPoint(this.date, this.value);
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<void> _dropAllTables(Database db) async {
    // Drop child tables first (those with foreign keys)
    await db.execute('DROP TABLE IF EXISTS routine_exercise_fact');
    await db.execute('DROP TABLE IF EXISTS workout_routine_fact');
    await db.execute('DROP TABLE IF EXISTS ai_routine_requests');
    await db.execute('DROP TABLE IF EXISTS user_custom_exercise_dim');
    await db.execute('DROP TABLE IF EXISTS exercise_library_dim');
    await db.execute('DROP TABLE IF EXISTS workout_session_fact');
    await db.execute('DROP TABLE IF EXISTS log_workout_fact');
    await db.execute('DROP TABLE IF EXISTS daily_activity_fact');
    await db.execute('DROP TABLE IF EXISTS user_dim');
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return await openDatabase(
      path,
      version: 30, // bump this when you change schema
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // During development: wipe and recreate
        await _dropAllTables(db);
        await _createAllTables(db);
        await _insertDefaultExercises(db);
        print(
          "Database upgraded from $oldVersion to $newVersion, tables recreated",
        );
      },
    );
  }

  Future<void> _createAllTables(Database db) async {
    // User table
    await db.execute('''
      CREATE TABLE user_dim (
        user_dim_id     INTEGER PRIMARY KEY AUTOINCREMENT
                                UNIQUE
                                NOT NULL,
        username        TEXT    NOT NULL,
        pwd             TEXT    NOT NULL,
        email           TEXT    NOT NULL,
        first_name      TEXT    NOT NULL,
        last_name       TEXT    NOT NULL,
        dob             TEXT    NOT NULL,
        phone_number    TEXT    NOT NULL,
        sex             TEXT    NOT NULL,
        weight          REAL    NOT NULL,
        weight_unit     TEXT    NOT NULL,
        height          REAL    NOT NULL,
        height_unit     TEXT    NOT NULL,
        age             INTEGER NOT NULL,
        RHR             REAL,
        health_conditions TEXT,
        custom_goals   TEXT,
        ai_avatar_id   INTEGER,
        ai_personality TEXT,
        ai_voice       TEXT,
        chatbot_summary TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE daily_activity_fact (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      total_steps INTEGER,
      total_distance REAL,
      total_calories INTEGER,
      average_heart_rate INTEGER,
      sleep_hours REAL,
      exercise_minutes INTEGER,
      sedentary_minutes INTEGER,
      active_minutes INTEGER,
      max_heart_rate INTEGER,
      sleep_deep_minutes INTEGER,
      sleep_light_minutes INTEGER,
      sleep_rem_minutes INTEGER,
      FOREIGN KEY(user_id) REFERENCES user_dim(user_dim_id),
      UNIQUE(user_id, date)
    )
  ''');

    await db.execute('''
    CREATE TABLE workout_session_fact (
      workout_session_fact_id TEXT PRIMARY KEY,
      user_id INTEGER NOT NULL,
      workout_name TEXT,
      workout_date TEXT,
      duration_min REAL,
      start_time TEXT,
      end_time TEXT,
      calories_burned REAL,
      avg_bpm REAL,
      max_bpm REAL,
      distance REAL
    )
  ''');

    await db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS unique_workout
    ON workout_session_fact(user_id, workout_date, workout_name, start_time)
  ''');

    // Exercise library table
    await db.execute('''
      CREATE TABLE exercise_library_dim (
        exercise_library_dim_id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
        exercise_name TEXT NOT NULL,
        target_area TEXT NOT NULL,
        description TEXT,
        equipment TEXT,
        instructions TEXT,
        warning TEXT,
        photo_position TEXT
      )
    ''');

    // User custom exercises table
    await db.execute('''
      CREATE TABLE user_custom_exercise_dim (
        user_exercise_dim_id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
        user_dim_id INTEGER NOT NULL,
        date_created TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        target_area TEXT NOT NULL,
        description TEXT,
        equipment TEXT,
        instructions TEXT,
        warning TEXT,
        photo_path TEXT,
        photo_url TEXT,
        FOREIGN KEY (user_dim_id) REFERENCES user_dim(user_dim_id)
      )
    ''');

    await _createWorkoutTables(db);
    await _createLogWorkoutTable(db);
  }

  // Create workout-related tables
  Future<void> _createWorkoutTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS workout_routine_fact (
      workout_routine_fact_id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
      user_dim_id INTEGER NOT NULL,
      workout_routine_name TEXT NOT NULL,
      created_at TEXT NOT NULL,
      is_ai_generated INTEGER DEFAULT 0,
      FOREIGN KEY (user_dim_id) REFERENCES user_dim(user_dim_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS routine_exercise_fact (
      routine_exercise_fact_id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
      workout_routine_fact_id INTEGER NOT NULL,
      exercise_library_dim_id INTEGER,
      user_exercise_dim_id INTEGER,
      repetitions INTEGER NOT NULL,
      sets INTEGER NOT NULL,
      weight INTEGER DEFAULT 0,
      weight_unit TEXT DEFAULT 'lbs',
      FOREIGN KEY (workout_routine_fact_id) REFERENCES workout_routine_fact(workout_routine_fact_id),
      FOREIGN KEY (exercise_library_dim_id) REFERENCES exercise_library_dim(exercise_library_dim_id),
      FOREIGN KEY (user_exercise_dim_id) REFERENCES user_custom_exercise_dim(user_exercise_dim_id),
      CHECK (
        (exercise_library_dim_id IS NOT NULL AND user_exercise_dim_id IS NULL)
        OR (exercise_library_dim_id IS NULL AND user_exercise_dim_id IS NOT NULL)
      )
    )
  ''');

    await db.execute('''
    CREATE TABLE ai_routine_requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      target_areas TEXT,
      duration_minutes INTEGER,
      intensity TEXT CHECK (intensity IN ('Light', 'Moderate', 'Intense')),
      goals TEXT,
      custom_goals TEXT,
      health_conditions TEXT, 
      fitness_level TEXT CHECK (fitness_level IN ('Beginner', 'Intermediate', 'Expert')),
      additional_comments TEXT,
      status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
      generated_routine_id INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES user_dim(user_dim_id) ON DELETE CASCADE
    )
  ''');
  }

  // Create log routine table for tracking actual workout performances
  Future<void> _createLogWorkoutTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS log_workout_fact (
        log_workout_fact_id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
        workout_routine_fact_id INTEGER NOT NULL,
        user_dim_id INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        log_duration INTEGER NOT NULL,
        calories_burned REAL,
        routine_name TEXT NOT NULL,
        FOREIGN KEY (workout_routine_fact_id) REFERENCES workout_routine_fact(workout_routine_fact_id),
        FOREIGN KEY (user_dim_id) REFERENCES user_dim(user_dim_id)
      )
    ''');
  }

  // Insert default exercises into the library
  Future<void> _insertDefaultExercises(Database db) async {
    final defaultExercises = [
      {
        'exercise_name': 'Push-ups',
        'target_area': 'Chest',
        'description':
        'Classic bodyweight exercise for chest, shoulders, and triceps',
        'equipment': 'None',
        'instructions':
        '1. Start in plank position\n2. Lower body to ground\n3. Push back up',
        'warning': 'Keep core tight and avoid sagging hips',
      },
      {
        'exercise_name': 'Squats',
        'target_area': 'Legs',
        'description': 'Fundamental lower body exercise',
        'equipment': 'None',
        'instructions':
        '1. Stand with feet shoulder-width apart\n2. Lower as if sitting in chair\n3. Return to standing',
        'warning': 'Keep knees aligned with toes',
      },
      {
        'exercise_name': 'Plank',
        'target_area': 'Core',
        'description': 'Isometric core strengthening exercise',
        'equipment': 'None',
        'instructions':
        '1. Start in push-up position\n2. Hold position on forearms\n3. Keep body straight',
        'warning': 'Avoid sagging hips or raising buttocks',
      },
      {
        'exercise_name': 'Pull-ups',
        'target_area': 'Back',
        'description': 'Upper body pulling exercise',
        'equipment': 'Pull-up bar',
        'instructions':
        '1. Hang from bar with palms facing away\n2. Pull body up until chin over bar\n3. Lower with control',
        'warning': 'Use full range of motion, avoid swinging',
      },
    ];
    for (final exercise in defaultExercises) {
      await db.insert('exercise_library_dim', exercise);
    }
  }

  Future<void> _updateCustomExerciseTables(Database db) async {
    try {
      // Check if photo_path column exists, if not add it
      var tableInfo = await db.rawQuery(
        'PRAGMA table_info(user_custom_exercise_dim)',
      );
      bool hasPhotoPath = tableInfo.any(
            (column) => column['name'] == 'photo_path',
      );
      bool hasPhotoUrl = tableInfo.any(
            (column) => column['name'] == 'photo_url',
      );

      if (!hasPhotoPath) {
        await db.execute(
          'ALTER TABLE user_custom_exercise_dim ADD COLUMN photo_path TEXT',
        );
      }
      if (!hasPhotoUrl) {
        await db.execute(
          'ALTER TABLE user_custom_exercise_dim ADD COLUMN photo_url TEXT',
        );
      }

      tableInfo = await db.rawQuery(
        'PRAGMA table_info(user_custom_exercise_dim)',
      );
      hasPhotoPath = tableInfo.any((column) => column['name'] == 'photo_path');
      hasPhotoUrl = tableInfo.any((column) => column['name'] == 'photo_url');

      if (!hasPhotoPath) {
        await db.execute(
          'ALTER TABLE user_custom_exercise_dim ADD COLUMN photo_path TEXT',
        );
      }
      if (!hasPhotoUrl) {
        await db.execute(
          'ALTER TABLE user_custom_exercise_dim ADD COLUMN photo_url TEXT',
        );
      }
    } catch (e) {}
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;

    final cleanedUser = <String, dynamic>{};

    user.forEach((key, value) {
      if (value == null || value.toString().trim().isEmpty) {
        cleanedUser[key] = null; // <-- keep null as null
        return;
      }

      switch (key) {
        case "weight":
        case "height":
        case "RHR":
        // Safely parse doubles and preserve null instead of forcing 0
          cleanedUser[key] =
          (value is num)
              ? value.toDouble()
              : double.tryParse(value.toString().trim());
          break;

        case "age":
        case "ai_avatar_id":
          cleanedUser[key] =
          (value is int) ? value : int.tryParse(value.toString().trim());
          break;

        default:
          cleanedUser[key] = value;
      }
    });

    print('Cleaned user before insert: $cleanedUser');

    return await dbClient.insert('user_dim', cleanedUser);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final dbClient = await db;
    return await dbClient.query('user_dim');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.query(
      'user_dim',
      where: 'user_dim_id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.update(
      'user_dim',
      data,
      where: 'user_dim_id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'user_dim',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<int> insertWorkoutRoutine(WorkoutRoutine routine) async {
    try {
      final dbClient = await db;
      final id = await dbClient.insert(
        'workout_routine_fact',
        routine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Workout routine created with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting workout routine: $e');
      rethrow;
    }
  }

  Future<int> insertRoutineExercise(RoutineExercise exercise) async {
    try {
      final dbClient = await db;
      final id = await dbClient.insert(
        'routine_exercise_fact',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Routine exercise added with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting routine exercise: $e');
      rethrow;
    }
  }

  Future<int> saveCompleteRoutine(
      WorkoutRoutine routine,
      List<RoutineExercise> exercises,
      ) async {
    try {
      final dbClient = await db;

      return await dbClient.transaction((txn) async {
        // Insert the routine first
        final routineId = await txn.insert(
          'workout_routine_fact',
          routine.toMap(),
        );

        // Insert all exercises for this routine
        for (final exercise in exercises) {
          final exerciseWithRoutineId = RoutineExercise(
            workoutRoutineFactId: routineId,
            exerciseLibraryDimId: exercise.exerciseLibraryDimId,
            userExerciseDimId: exercise.userExerciseDimId,
            repetitions: exercise.repetitions,
            sets: exercise.sets,
            weight: exercise.weight,
            weightUnit: exercise.weightUnit,
          );

          await txn.insert(
            'routine_exercise_fact',
            exerciseWithRoutineId.toMap(),
          );
        }

        print(
          'Complete routine saved with ID: $routineId and ${exercises.length} exercises',
        );
        return routineId;
      });
    } catch (e) {
      print('Error saving complete routine: $e');
      rethrow;
    }
  }

  Future<List<WorkoutRoutine>> getWorkoutRoutinesByUser(int userId) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'workout_routine_fact',
        where: 'user_dim_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => WorkoutRoutine.fromMap(map)).toList();
    } catch (e) {
      print('Error getting workout routines: $e');
      return [];
    }
  }

  Future<List<RoutineExercise>> getRoutineExercisesWithDetails(
      int routineId,
      ) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.rawQuery(
        '''
        SELECT 
          re.*,
          COALESCE(el.exercise_name, ce.exercise_name) as exercise_name,
          COALESCE(el.target_area, ce.target_area) as target_area
        FROM routine_exercise_fact re
        LEFT JOIN exercise_library_dim el ON re.exercise_library_dim_id = el.exercise_library_dim_id
        LEFT JOIN user_custom_exercise_dim ce ON re.user_exercise_dim_id = ce.user_exercise_dim_id
        WHERE re.workout_routine_fact_id = ?
        ORDER BY re.routine_exercise_fact_id ASC
      ''',
        [routineId],
      );

      return maps.map((map) => RoutineExercise.fromMap(map)).toList();
    } catch (e) {
      print('Error getting routine exercises: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCompleteRoutine(int routineId) async {
    try {
      final dbClient = await db;

      // Get routine details
      final routineMaps = await dbClient.query(
        'workout_routine_fact',
        where: 'workout_routine_fact_id = ?',
        whereArgs: [routineId],
        limit: 1,
      );

      if (routineMaps.isEmpty) return null;

      final routine = WorkoutRoutine.fromMap(routineMaps.first);
      final exercises = await getRoutineExercisesWithDetails(routineId);

      return {'routine': routine, 'exercises': exercises};
    } catch (e) {
      print('Error getting complete routine: $e');
      return null;
    }
  }

  Future<int> deleteWorkoutRoutine(int routineId) async {
    try {
      final dbClient = await db;

      return await dbClient.transaction((txn) async {
        // Delete all exercises first
        await txn.delete(
          'routine_exercise_fact',
          where: 'workout_routine_fact_id = ?',
          whereArgs: [routineId],
        );

        // Then delete the routine
        final rowsAffected = await txn.delete(
          'workout_routine_fact',
          where: 'workout_routine_fact_id = ?',
          whereArgs: [routineId],
        );

        print('Routine and exercises deleted');
        return rowsAffected;
      });
    } catch (e) {
      print('Error deleting workout routine: $e');
      rethrow;
    }
  }

  Future<int> insertCustomExercise(CustomExercise exercise) async {
    try {
      final dbClient = await db;
      final id = await dbClient.insert(
        'user_custom_exercise_dim',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Custom exercise created with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting custom exercise: $e');
      rethrow;
    }
  }

  Future<List<CustomExercise>> getCustomExercisesByUser(int userId) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'user_custom_exercise_dim',
        where: 'user_dim_id = ?',
        whereArgs: [userId],
        orderBy: 'date_created DESC',
      );

      return maps.map((map) => CustomExercise.fromMap(map)).toList();
    } catch (e) {
      print('Error getting custom exercises: $e');
      return [];
    }
  }

  Future<CustomExercise?> getCustomExerciseById(int exerciseId) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'user_custom_exercise_dim',
        where: 'user_exercise_dim_id = ?',
        whereArgs: [exerciseId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return CustomExercise.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting custom exercise by ID: $e');
      return null;
    }
  }

  Future<int> updateCustomExercise(CustomExercise exercise) async {
    try {
      final dbClient = await db;
      final rowsAffected = await dbClient.update(
        'user_custom_exercise_dim',
        exercise.toMap(),
        where: 'user_exercise_dim_id = ?',
        whereArgs: [exercise.id],
      );

      if (rowsAffected > 0) {
        print('Custom exercise updated successfully');
      } else {
        print('No exercise found with ID: ${exercise.id}');
      }

      return rowsAffected;
    } catch (e) {
      print('Error updating custom exercise: $e');
      rethrow;
    }
  }

  Future<int> deleteCustomExercise(int exerciseId) async {
    try {
      final dbClient = await db;
      final rowsAffected = await dbClient.delete(
        'user_custom_exercise_dim',
        where: 'user_exercise_dim_id = ?',
        whereArgs: [exerciseId],
      );

      if (rowsAffected > 0) {
        print('Custom exercise deleted successfully');
      } else {
        print('No exercise found with ID: $exerciseId');
      }

      return rowsAffected;
    } catch (e) {
      print('Error deleting custom exercise: $e');
      rethrow;
    }
  }

  Future<List<CustomExercise>> searchCustomExercises(
      int userId,
      String searchTerm,
      ) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'user_custom_exercise_dim',
        where:
        'user_dim_id = ? AND (exercise_name LIKE ? OR target_area LIKE ?)',
        whereArgs: [userId, '%$searchTerm%', '%$searchTerm%'],
        orderBy: 'exercise_name ASC',
      );

      return maps.map((map) => CustomExercise.fromMap(map)).toList();
    } catch (e) {
      print('Error searching custom exercises: $e');
      return [];
    }
  }

  Future<List<ExerciseLibrary>> getAllLibraryExercises() async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'exercise_library_dim',
        orderBy: 'exercise_name ASC',
      );

      return maps.map((map) => ExerciseLibrary.fromMap(map)).toList();
    } catch (e) {
      print('Error getting library exercises: $e');
      return [];
    }
  }

  Future<List<ExerciseLibrary>> getLibraryExercisesByTargetArea(
      String targetArea,
      ) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'exercise_library_dim',
        where: 'target_area = ?',
        whereArgs: [targetArea],
        orderBy: 'exercise_name ASC',
      );

      return maps.map((map) => ExerciseLibrary.fromMap(map)).toList();
    } catch (e) {
      print('Error getting exercises by target area: $e');
      return [];
    }
  }

  Future<List<ExerciseLibrary>> searchLibraryExercises(
      String searchTerm,
      ) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'exercise_library_dim',
        where: 'exercise_name LIKE ? OR target_area LIKE ?',
        whereArgs: ['%$searchTerm%', '%$searchTerm%'],
        orderBy: 'exercise_name ASC',
      );

      return maps.map((map) => ExerciseLibrary.fromMap(map)).toList();
    } catch (e) {
      print('Error searching library exercises: $e');
      return [];
    }
  }

  Future<int> insertLibraryExercise(ExerciseLibrary exercise) async {
    try {
      final dbClient = await db;
      final id = await dbClient.insert(
        'exercise_library_dim',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Library exercise created with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting library exercise: $e');
      rethrow;
    }
  }

  Future<int> insertAIRoutineRequest(AIRoutineRequest request) async {
    final dbClient = await db;
    final now = DateTime.now().toIso8601String();

    final requestMap = request.toMap();
    requestMap['created_at'] = now;
    requestMap['updated_at'] = now;

    return await dbClient.insert('ai_routine_requests', requestMap);
  }

  Future<int> updateAIRoutineRequest(AIRoutineRequest request) async {
    final dbClient = await db;
    final requestMap = request.toMap();
    requestMap['updated_at'] = DateTime.now().toIso8601String();

    return await dbClient.update(
      'ai_routine_requests',
      requestMap,
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  Future<AIRoutineRequest?> getAIRoutineRequest(int id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'ai_routine_requests',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AIRoutineRequest.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AIRoutineRequest>> getUserAIRoutineRequests(int userId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'ai_routine_requests',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AIRoutineRequest.fromMap(maps[i]);
    });
  }

  Future<List<AIRoutineRequest>> getRequestsByStatus(String status) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'ai_routine_requests',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AIRoutineRequest.fromMap(maps[i]);
    });
  }

  Future<int> updateRequestStatus(int id, String status) async {
    final dbClient = await db;
    return await dbClient.update(
      'ai_routine_requests',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAIRoutineRequest(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'ai_routine_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insert(
      String table,
      Map<String, dynamic> values, {
        ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
      }) async {
    final dbClient = await db;
    return await dbClient.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<void> printTable(String tableName) async {
    final dbClient = await db;
    final result = await dbClient.query(tableName);

    print("Contents of $tableName (${result.length} rows):");
    for (var row in result) {
      print(row); // each row is a Map<String, dynamic>
    }
  }

  Future<int> insertWorkoutLog(WorkoutLog log) async {
    try {
      final dbClient = await db;
      final id = await dbClient.insert(
        'log_workout_fact',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Workout log created with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting workout log: $e');
      rethrow;
    }
  }

  Future<List<WorkoutLog>> getWorkoutLogsByUser(
      int userId, {
        int? limit,
      }) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'log_workout_fact',
        where: 'user_dim_id = ?',
        whereArgs: [userId],
        orderBy: 'log_date DESC',
        limit: limit,
      );

      return maps.map((map) => WorkoutLog.fromMap(map)).toList();
    } catch (e) {
      print('Error getting workout logs: $e');
      return [];
    }
  }

  Future<List<WorkoutLog>> getRecentWorkoutHistory(int userId) async {
    return await getWorkoutLogsByUser(userId, limit: 10);
  }

  Future<List<WorkoutLog>> getWorkoutLogsByDateRange(
      int userId,
      String startDate,
      String endDate,
      ) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'log_workout_fact',
        where: 'user_dim_id = ? AND log_date BETWEEN ? AND ?',
        whereArgs: [userId, startDate, endDate],
        orderBy: 'log_date DESC',
      );

      return maps.map((map) => WorkoutLog.fromMap(map)).toList();
    } catch (e) {
      print('Error getting workout logs by date range: $e');
      return [];
    }
  }

  Future<int> updateWorkoutLog(WorkoutLog log) async {
    try {
      final dbClient = await db;
      final rowsAffected = await dbClient.update(
        'log_workout_fact',
        log.toMap(),
        where: 'log_workout_fact_id = ?',
        whereArgs: [log.id],
      );

      if (rowsAffected > 0) {
        print('Workout log updated successfully');
      } else {
        print('No workout log found with ID: ${log.id}');
      }

      return rowsAffected;
    } catch (e) {
      print('Error updating workout log: $e');
      rethrow;
    }
  }

  Future<int> deleteWorkoutLog(int logId) async {
    try {
      final dbClient = await db;
      final rowsAffected = await dbClient.delete(
        'log_workout_fact',
        where: 'log_workout_fact_id = ?',
        whereArgs: [logId],
      );

      if (rowsAffected > 0) {
        print('Workout log deleted successfully');
      } else {
        print('No workout log found with ID: $logId');
      }

      return rowsAffected;
    } catch (e) {
      print('Error deleting workout log: $e');
      rethrow;
    }
  }

  Future<WorkoutLog?> getWorkoutLogById(int logId) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'log_workout_fact',
        where: 'log_workout_fact_id = ?',
        whereArgs: [logId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return WorkoutLog.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting workout log by ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRoutinesForDropdown(int userId) async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query(
        'workout_routine_fact',
        columns: ['workout_routine_fact_id', 'workout_routine_name'],
        where: 'user_dim_id = ?',
        whereArgs: [userId],
        orderBy: 'workout_routine_name ASC',
      );

      return maps;
    } catch (e) {
      print('Error getting workout routines for dropdown: $e');
      return [];
    }
  }

  Future<void> printDayData(DateTime day) async {
    final dbClient = await db;

    // Format date string exactly the same way you store it (ISO 8601)
    final dateString = DateTime(day.year, day.month, day.day).toIso8601String();

    // Query
    final rows = await dbClient.query(
      'daily_activity_fact',
      where: 'date = ?',
      whereArgs: [dateString],
    );

    if (rows.isEmpty) {
      print("No data found for $dateString");
      return;
    }

    for (var row in rows) {
      print(row);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutLogs(int userId) async {
    final dbClient = await db;

    final rows = await dbClient.query(
      'workout_session_fact',
      columns: [
        'workout_name',
        'workout_date', // e.g., '2024-10-07'
        'duration_min', // REAL
        'calories_burned', // REAL
      ],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'workout_date DESC, start_time ASC',
      limit: 30,
    );
    return rows;
  }

  Future<void> insertMockWorkoutSessions(int userId) async {
    final dbClient = await db;
    const uuid = Uuid();

    final mockSessions = [
      {
        'workout_session_fact_id': uuid.v4(),
        'user_id': userId,
        'workout_name': 'Running',
        'workout_date': '2024-10-12',
        'duration_min': 36.0,
        'start_time': '07:10',
        'end_time': '07:46',
        'calories_burned': 315.0,
        'avg_bpm': 132.0,
        'max_bpm': 168.0,
        'distance': 5.4,
      },
      {
        'workout_session_fact_id': uuid.v4(),
        'user_id': userId,
        'workout_name': 'Yoga',
        'workout_date': '2024-10-13',
        'duration_min': 45.0,
        'start_time': '18:05',
        'end_time': '18:50',
        'calories_burned': 185.0,
        'avg_bpm': 92.0,
        'max_bpm': 112.0,
        'distance': 0.0,
      },
      {
        'workout_session_fact_id': uuid.v4(),
        'user_id': userId,
        'workout_name': 'Cycling',
        'workout_date': '2024-10-14',
        'duration_min': 50.0,
        'start_time': '08:20',
        'end_time': '09:10',
        'calories_burned': 425.0,
        'avg_bpm': 136.0,
        'max_bpm': 173.0,
        'distance': 14.8,
      },
    ];

    final batch = dbClient.batch();
    for (final session in mockSessions) {
      batch.insert(
        'workout_session_fact',
        session,
        conflictAlgorithm: ConflictAlgorithm.ignore, // or replace if desired
      );
    }

    await batch.commit(noResult: true);
  }

  Future<ActivityStats?> getDailyStats({
    required int userId,
    DateTime? day,
  }) async {
    final dbc = await db;
    final ymd = day?.toIso8601String().split('T').first;

    final rows = await dbc.query(
      'daily_activity_fact',
      columns: [
        'total_steps',
        'total_calories',
        'average_heart_rate',
        'max_heart_rate',
        'exercise_minutes',
        'sedentary_minutes',
        'active_minutes',
        'sleep_hours',
        'total_distance',
        'sleep_deep_minutes',
        'sleep_light_minutes',
        'sleep_rem_minutes',
      ],
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, ymd],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final r = rows.first;

    return ActivityStats(
      steps: (r['total_steps'] ?? 0) as int,
      calories: (r['total_calories'] ?? 0) as int,
      avgBpm: (r['average_heart_rate'] ?? 0) as int,
      maxBpm: (r['max_heart_rate'] ?? 0) as int,
      exerciseMinutes: (r['exercise_minutes'] ?? 0) as int,
      sleepHours: (r['sleep_hours'] as num?)?.toDouble() ?? 0.0,
      sedentaryHours:
      ((r['sedentary_minutes'] ?? 0) as num).toDouble() / 60.0,
      activeHours:
      ((r['active_minutes'] ?? 0) as num).toDouble() / 60.0,
      distance: (r['total_distance'] as num?)?.toDouble() ?? 0.0,
      sleepDeepMinutes: (r['sleep_deep_minutes'] ?? 0) as int,
      sleepLightMinutes: (r['sleep_light_minutes'] ?? 0) as int,
      sleepRemMinutes: (r['sleep_rem_minutes'] ?? 0) as int,
    );
  }

  Future<List<DailyPoint>> getWeekActivity({
    required int userId,
    required DateTime weekStart,
    required Metric metric,
  }) async {
    final dbclient = await db;
    final start = _mondayOf(weekStart);
    final end = start.add(const Duration(days: 6));

    final col = (metric == Metric.steps) ? 'total_steps' : 'total_calories';

    final rows = await dbclient.rawQuery(
      '''
      SELECT date, $col AS val
      FROM daily_activity_fact
      WHERE user_id = ?
        AND date BETWEEN ? AND ?
      ORDER BY date ASC
    ''',
      [
        userId,
        start.toIso8601String().split('T').first,
        end.toIso8601String().split('T').first,
      ],
    );

    // Map results for quick lookup
    final map = <String, double>{};
    for (final r in rows) {
      final k = (r['date'] as String);
      final v = (r['val'] as num?)?.toDouble() ?? 0.0;
      map[k] = v;
    }

    // Return exactly 7 points (Mon..Sun), fill missing with 0
    return List.generate(7, (i) {
      final d = start.add(Duration(days: i));
      return DailyPoint(d, map[d.toIso8601String().split('T').first] ?? 0.0);
    });
  }

  Future<void> insertMockDailyData(int userId) async {
    final dbClient = await db;

    final today = DateTime.now();
    final List<DateTime> days = List.generate(
      14,
          (i) => today.subtract(Duration(days: 13 - i)),
    );

    final mockTemplate = [
      {
        'total_steps': 8500,
        'total_distance': 6.3,
        'total_calories': 2100,
        'average_heart_rate': 78,
        'sleep_hours': 7.2,
        'exercise_minutes': 45,
        'sedentary_minutes': 420,
        'active_minutes': 180,
        'max_heart_rate': 128,
      },
      {
        'total_steps': 10400,
        'total_distance': 7.5,
        'total_calories': 2350,
        'average_heart_rate': 82,
        'sleep_hours': 6.8,
        'exercise_minutes': 60,
        'sedentary_minutes': 480,
        'active_minutes': 200,
        'max_heart_rate': 140,
      },
      {
        'total_steps': 5200,
        'total_distance': 3.9,
        'total_calories': 1800,
        'average_heart_rate': 70,
        'sleep_hours': 8.1,
        'exercise_minutes': 20,
        'sedentary_minutes': 510,
        'active_minutes': 100,
        'max_heart_rate': 115,
      },
      {
        'total_steps': 12100,
        'total_distance': 8.6,
        'total_calories': 2600,
        'average_heart_rate': 88,
        'sleep_hours': 7.5,
        'exercise_minutes': 70,
        'sedentary_minutes': 400,
        'active_minutes': 220,
        'max_heart_rate': 150,
      },
      {
        'total_steps': 9600,
        'total_distance': 6.9,
        'total_calories': 2250,
        'average_heart_rate': 76,
        'sleep_hours': 7.0,
        'exercise_minutes': 50,
        'sedentary_minutes': 450,
        'active_minutes': 160,
        'max_heart_rate': 130,
      },
      {
        'total_steps': 6400,
        'total_distance': 4.2,
        'total_calories': 1900,
        'average_heart_rate': 74,
        'sleep_hours': 8.3,
        'exercise_minutes': 35,
        'sedentary_minutes': 490,
        'active_minutes': 120,
        'max_heart_rate': 125,
      },
      {
        'total_steps': 7200,
        'total_distance': 5.0,
        'total_calories': 2000,
        'average_heart_rate': 72,
        'sleep_hours': 8.0,
        'exercise_minutes': 40,
        'sedentary_minutes': 460,
        'active_minutes': 130,
        'max_heart_rate': 127,
      },
      {
        'total_steps': 8800,
        'total_distance': 6.7,
        'total_calories': 2200,
        'average_heart_rate': 79,
        'sleep_hours': 7.6,
        'exercise_minutes': 50,
        'sedentary_minutes': 430,
        'active_minutes': 190,
        'max_heart_rate': 132,
      },
      {
        'total_steps': 11100,
        'total_distance': 8.1,
        'total_calories': 2450,
        'average_heart_rate': 84,
        'sleep_hours': 7.1,
        'exercise_minutes': 65,
        'sedentary_minutes': 470,
        'active_minutes': 210,
        'max_heart_rate': 142,
      },
      {
        'total_steps': 5600,
        'total_distance': 4.1,
        'total_calories': 1850,
        'average_heart_rate': 72,
        'sleep_hours': 8.4,
        'exercise_minutes': 25,
        'sedentary_minutes': 500,
        'active_minutes': 110,
        'max_heart_rate': 118,
      },
      {
        'total_steps': 12400,
        'total_distance': 8.8,
        'total_calories': 2650,
        'average_heart_rate': 89,
        'sleep_hours': 7.4,
        'exercise_minutes': 75,
        'sedentary_minutes': 390,
        'active_minutes': 230,
        'max_heart_rate': 155,
      },
      {
        'total_steps': 9800,
        'total_distance': 7.0,
        'total_calories': 2300,
        'average_heart_rate': 77,
        'sleep_hours': 7.3,
        'exercise_minutes': 55,
        'sedentary_minutes': 440,
        'active_minutes': 170,
        'max_heart_rate': 133,
      },
      {
        'total_steps': 6700,
        'total_distance': 4.6,
        'total_calories': 1950,
        'average_heart_rate': 75,
        'sleep_hours': 8.2,
        'exercise_minutes': 30,
        'sedentary_minutes': 480,
        'active_minutes': 125,
        'max_heart_rate': 126,
      },
      {
        'total_steps': 7400,
        'total_distance': 5.3,
        'total_calories': 2050,
        'average_heart_rate': 73,
        'sleep_hours': 8.1,
        'exercise_minutes': 45,
        'sedentary_minutes': 450,
        'active_minutes': 140,
        'max_heart_rate': 128,
      },
    ];

    final mockData = List.generate(14, (i) {
      final record = Map<String, dynamic>.from(
        mockTemplate[i % mockTemplate.length],
      );
      record['user_id'] = userId;
      record['date'] = days[i].toIso8601String().split('T').first; // YYYY-MM-DD
      return record;
    });

    final batch = dbClient.batch();
    for (final record in mockData) {
      batch.insert(
        'daily_activity_fact',
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}

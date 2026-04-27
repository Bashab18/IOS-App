import 'package:mhealthapp/health/health_package.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthDataSyncService {
  /// Fetch today's summary from Health API and store in SQLite
  static Future<void> syncToSQLite() async {
    print("syncToSQLite started");
    try {
      // Ensure permissions are still valid
      // bool hasPerms = await HealthPermissions.requestPermissions();
      // if (!hasPerms) {
      //   print("No health permissions, skipping sync");
      //   return;
      // }

      // Fetch today's summary
      final prefs = await SharedPreferences.getInstance();
      print("SharedPreferences loaded");
      final int? id = prefs.getInt('userId');
      final dbHelper = DBHelper();
      print("Database initialized");

      print("Fetching today summary...");
      final todaySummary = await HealthAPI.getTodaySummary().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception("getTodaySummary timed out in background");
        },
      );
      print("Today summary fetched: $todaySummary");
      print("Fetching today workout...");
      final todayworkouts = await HealthRepository().getTodayworkout().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception("getTodayworkout timed out in background");
        },
      );
      print("Workouts fetched: ${todayworkouts.length}");

      // Insert into SQLite

      await dbHelper.insert(
        'daily_activity_fact',
        todaySummary.toMap(userId: id),
      );
      print("Daily activity inserted");
      for (var session in todayworkouts) {
        await dbHelper.insert(
          'workout_session_fact',
          session.toMap(userId: id),
        );
      }
      print("Workouts inserted");
      print("Health data synced at ${DateTime.now()}");
      await dbHelper.printTable("workout_session_fact");
      await dbHelper.printTable("daily_activity_fact");
    } catch (e, s) {
      print("Sync failed: $e");
      print(s);
    }
  }

  static Future<void> syncYesterdayToSQLite() async {
    print("syncYesterdayToSQLite started");
    try {
      // Ensure permissions are still valid
      // bool hasPerms = await HealthPermissions.requestPermissions();
      // if (!hasPerms) {
      //   print("No health permissions, skipping sync");
      //   return;
      // }

      // Fetch today's summary
      final prefs = await SharedPreferences.getInstance();
      print("SharedPreferences loaded");
      final int? id = prefs.getInt('userId');
      final dbHelper = DBHelper();
      print("Database initialized");

      print("Fetching Yesterday summary...");
      final yesterdaySummary = await HealthAPI.getYesterdaySummary().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception("getYesterdaySummary timed out in background");
        },
      );
      print("Yesterday summary fetched: $yesterdaySummary");
      print("Fetching Yesterday workout...");
      final yesterdayworkouts = await HealthRepository()
          .getYesterdayworkout()
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception("getYesterdayworkout timed out in background");
            },
          );
      print("Workouts fetched: ${yesterdayworkouts.length}");

      // Insert into SQLite

      await dbHelper.insert(
        'daily_activity_fact',
        yesterdaySummary.toMap(userId: id),
      );
      print("Daily activity inserted");
      for (var session in yesterdayworkouts) {
        await dbHelper.insert(
          'workout_session_fact',
          session.toMap(userId: id),
        );
      }
      print("Workouts inserted");
      print("Health data synced at ${DateTime.now()}");
      await dbHelper.printTable("workout_session_fact");
      await dbHelper.printTable("daily_activity_fact");
    } catch (e, s) {
      print("Sync failed: $e");
      print(s);
    }
  }
}

import 'health_service.dart';
import 'health_data_model.dart';

class HealthAPI {
  static final HealthService _service = HealthService();

  // Static API endpoints for easy access
  static Future<List<HealthDataModel>> getTodayData() async {
    return await _service.getData(period: HealthDataPeriod.today);
  }

  static Future<List<HealthDataModel>> getWeekData() async {
    return await _service.getData(period: HealthDataPeriod.thisWeek);
  }

  static Future<List<HealthDataModel>> getMonthData() async {
    return await _service.getData(period: HealthDataPeriod.thisMonth);
  }

  static Future<List<HealthDataModel>> getCustomData(
    DateTime start,
    DateTime end,
  ) async {
    return await _service.getData(
      period: HealthDataPeriod.custom,
      start: start,
      end: end,
    );
  }

  static Future<HealthSummary> getTodaySummary() async {
    return await _service.getSummary(period: HealthDataPeriod.today);
  }

  static Future<HealthSummary> getYesterdaySummary() async {
    return await _service.getSummary(period: HealthDataPeriod.yesterday);
  }

  static Future<HealthSummary> getDateSummary(DateTime date) async {
    return await _service.getSummary(
      period: HealthDataPeriod.custom,
      date: date,
    );
  }

  static Future<List<HealthSummary>> getWeeklySummary() async {
    return await _service.getWeeklySummary();
  }

  // Steps API
  static Future<List<HealthDataModel>> getTodaySteps() async {
    return await _service.getSteps(period: HealthDataPeriod.today);
  }

  static Future<List<HealthDataModel>> getStepsForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    return await _service.getSteps(
      period: HealthDataPeriod.custom,
      start: start,
      end: end,
    );
  }

  // Heart Rate API
  static Future<List<HealthDataModel>> getTodayHeartRate() async {
    return await _service.getHeartRate(period: HealthDataPeriod.today);
  }

  static Future<List<HealthDataModel>> getHeartRateForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    return await _service.getHeartRate(
      period: HealthDataPeriod.custom,
      start: start,
      end: end,
    );
  }

  // Write Data API
  static Future<bool> addSteps(
    int steps, {
    DateTime? start,
    DateTime? end,
  }) async {
    return await _service.writeSteps(steps, start: start, end: end);
  }

  static Future<bool> addWeight(double weight, {DateTime? dateTime}) async {
    return await _service.writeWeight(weight, dateTime: dateTime);
  }

  static Future<bool> addHeartRate(int heartRate, {DateTime? dateTime}) async {
    return await _service.writeHeartRate(heartRate, dateTime: dateTime);
  }

  // Permission API
  static Future<bool> hasPermissions() async {
    return await _service.checkPermissions();
  }

  static Future<bool> requestPermissions() async {
    return await _service.requestPermissions();
  }

  static Future<bool> isHealthConnectAvailable() async {
    return await _service.isHealthConnectInstalled();
  }

  // Enhanced Data APIs based on mHealth database structure

  // // Sleep Data API
  // static Future<DetailedSleepData?> getDetailedSleepData(DateTime date) async {
  //   return await _service.getDetailedSleepData(date);
  // }

  // static Future<List<DetailedSleepData>> getSleepDataForPeriod(DateTime start, DateTime end) async {
  //   return await _service.getSleepDataForPeriod(start, end);
  // }

  // // Detailed Heart Rate API
  // static Future<List<DetailedHeartRateData>> getDetailedHeartRateData(DateTime start, DateTime end) async {
  //   return await _service.getDetailedHeartRateData(start, end);
  // }

  // static Future<Map<String, double>> getHeartRateStatistics(DateTime date) async {
  //   return await _service.getHeartRateStatistics(date);
  // }

  // // Workout and Exercise APIs
  // static Future<List<WorkoutSession>> getWorkoutSessions(
  //   DateTime start,
  //   DateTime end,
  // ) async {
  //   return await _service.getWorkoutSessions(start, end);
  // }

  // static Future<List<ExerciseLog>> getExerciseLogs(DateTime start, DateTime end) async {
  //   return await _service.getExerciseLogs(start, end);
  // }

  // static Future<bool> logWorkoutSession(WorkoutSession session) async {
  //   return await _service.logWorkoutSession(session);
  // }

  // static Future<bool> logExercise(ExerciseLog exercise) async {
  //   return await _service.logExercise(exercise);
  // }

  // Activity and Movement APIs
  // static Future<Map<String, int>> getActivityMinutes(DateTime date) async {
  //   return await _service.getActivityMinutes(date);
  // }

  // static Future<Map<String, double>> getEnergyData(DateTime date) async {
  //   return await _service.getEnergyData(date);
  // }

  // // User Profile API
  // static Future<UserProfile?> getUserProfile() async {
  //   return await _service.getUserProfile();
  // }

  // static Future<bool> updateUserProfile(UserProfile profile) async {
  //   return await _service.updateUserProfile(profile);
  // }

  // // Stand/Move Goals API
  // static Future<Map<String, int>> getStandData(DateTime date) async {
  //   return await _service.getStandData(date);
  // }

  // // Enhanced Summary with detailed metrics
  // static Future<HealthSummary> getEnhancedDailySummary(DateTime date) async {
  //   return await _service.getEnhancedDailySummary(date);
  // }

  // // Data Export API for mHealth compatibility
  // static Future<Map<String, dynamic>> exportHealthDataForDate(DateTime date) async {
  //   return await _service.exportHealthDataForDate(date);
  // }

  // static Future<List<Map<String, dynamic>>> exportHealthDataForPeriod(DateTime start, DateTime end) async {
  //   return await _service.exportHealthDataForPeriod(start, end);
  // }

  // Utility methods
  static Future<bool> initialize() async {
    bool isAvailable = await isHealthConnectAvailable();
    if (!isAvailable) {
      return false;
    }
    return await hasPermissions();
  }

  static Future<bool> ensurePermissions() async {
    bool hasPerms = await hasPermissions();
    if (!hasPerms) {
      return await requestPermissions();
    }
    return true;
  }
}

import 'package:health/health.dart';
import 'health_data_model.dart';
import 'health_permissions.dart';

class HealthRepository {
  final Health _health = Health();

  Future<List<HealthDataModel>> getTodayData() async {
    return getDataForDate(DateTime.now());
  }

  Future<List<HealthDataModel>> getYesterdayData() async {
    return getDataForDate(DateTime.now().subtract(const Duration(days: 1)));
  }

  Future<List<HealthDataModel>> getDataForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getDataForPeriod(startOfDay, endOfDay);
  }

  Future<List<HealthDataModel>> getDataForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      // bool hasPermissions = await HealthPermissions.checkPermissions();
      // if (!hasPermissions) {
      //   print('No health data permissions');
      //   throw Exception('No health data permissions');
      // }

      print('Fetching health data from $start to $end');
      print(
        'Data types: ${HealthPermissions.requiredDataTypes.map((t) => t.name).join(', ')}',
      );

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: HealthPermissions.requiredDataTypes,
        startTime: start,
        endTime: end,
      );

      print('Found ${healthData.length} health data points');
      // for (var point in healthData) {
      //   print(
      //     '${point.type.name}: ${point.value} ${point.unit.name} from ${point.dateFrom} to ${point.dateTo}',
      //   );
      // }

      return healthData
          .map((point) => HealthDataModel.fromHealthDataPoint(point))
          .toList();
    } catch (e) {
      print('Error fetching health data: $e');
      rethrow;
    }
  }

  Future<HealthSummary> getTodaySummary() async {
    final today = DateTime.now();
    final data = await getTodayData();
    return HealthSummary.fromHealthData(data, today);
  }

  Future<HealthSummary> getYesterdaySummary() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final data = await getYesterdayData();
    return HealthSummary.fromHealthData(data, yesterday);
  }

  Future<List<WorkoutSession>> getTodayworkout() async {
    final today = DateTime.now();
    final data = await getTodayData();
    final workoutPoints =
        data.where((p) => p.workoutActivityType != null).toList();
    final heartRatePoints =
        data.where((p) => p.type == HealthDataType.HEART_RATE).toList();
    final sessions =
        workoutPoints.map((w) {
          return WorkoutSession.fromHealthDataPoints(w, heartRatePoints, today);
        }).toList();
    return sessions;
  }

  Future<List<WorkoutSession>> getYesterdayworkout() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final data = await getYesterdayData();
    final workoutPoints =
        data.where((p) => p.workoutActivityType != null).toList();
    final heartRatePoints =
        data.where((p) => p.type == HealthDataType.HEART_RATE).toList();
    final sessions =
        workoutPoints.map((w) {
          return WorkoutSession.fromHealthDataPoints(
            w,
            heartRatePoints,
            yesterday,
          );
        }).toList();
    return sessions;
  }

  Future<HealthSummary> getSummaryForDate(DateTime date) async {
    final data = await getDataForDate(date);
    return HealthSummary.fromHealthData(data, date);
  }

  Future<List<HealthSummary>> getWeeklySummary() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<HealthSummary> weeklySummaries = [];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      if (date.isBefore(now.add(Duration(days: 1)))) {
        try {
          final summary = await getSummaryForDate(date);
          weeklySummaries.add(summary);
        } catch (e) {
          print('error happens when retrieving ${date.toString()}: $e');
        }
      }
    }

    return weeklySummaries;
  }

  Future<bool> writeSteps(int steps, DateTime start, DateTime end) async {
    try {
      bool hasPermissions = await HealthPermissions.checkPermissions();
      if (!hasPermissions) {
        throw Exception('No health data permissions');
      }

      return await _health.writeHealthData(
        value: steps.toDouble(),
        type: HealthDataType.STEPS,
        startTime: start,
        endTime: end,
      );
    } catch (e) {
      print('Error writing step data: $e');
      return false;
    }
  }

  Future<bool> writeWeight(double weight, DateTime dateTime) async {
    try {
      bool hasPermissions = await HealthPermissions.checkPermissions();
      if (!hasPermissions) {
        throw Exception('No health data permissions');
      }

      return await _health.writeHealthData(
        value: weight,
        type: HealthDataType.WEIGHT,
        startTime: dateTime,
        endTime: dateTime,
      );
    } catch (e) {
      print('Error writing weight data: $e');
      return false;
    }
  }

  Future<bool> writeHeartRate(int heartRate, DateTime dateTime) async {
    try {
      bool hasPermissions = await HealthPermissions.checkPermissions();
      if (!hasPermissions) {
        throw Exception('No health data permissions');
      }

      return await _health.writeHealthData(
        value: heartRate.toDouble(),
        type: HealthDataType.HEART_RATE,
        startTime: dateTime,
        endTime: dateTime,
      );
    } catch (e) {
      print('Error writing heart rate data: $e');
      return false;
    }
  }

  Future<bool> writeActiveEnergeBurned(
    int activeenergeburned,
    DateTime dateTime,
  ) async {
    try {
      bool hasPermissions = await HealthPermissions.checkPermissions();
      if (!hasPermissions) {
        throw Exception('No health data permissions');
      }

      return await _health.writeHealthData(
        value: activeenergeburned.toDouble(),
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: dateTime,
        endTime: dateTime,
      );
    } catch (e) {
      print('Error writing activeenergebured data: $e');
      return false;
    }
  }

  Future<bool> writebasalEnergeBurned(
    int activeenergeburned,
    DateTime dateTime,
  ) async {
    try {
      bool hasPermissions = await HealthPermissions.checkPermissions();
      if (!hasPermissions) {
        throw Exception('No health data permissions');
      }

      return await _health.writeHealthData(
        value: activeenergeburned.toDouble(),
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: dateTime,
        endTime: dateTime,
      );
    } catch (e) {
      print('Error writing basalenergebured data: $e');
      return false;
    }
  }

  Future<List<HealthDataModel>> getStepsData(
    DateTime start,
    DateTime end,
  ) async {
    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      return healthData
          .where((point) => point.type == HealthDataType.STEPS)
          .map((point) => HealthDataModel.fromHealthDataPoint(point))
          .toList();
    } catch (e) {
      print('Error getting step data: $e');
      return [];
    }
  }

  Future<List<HealthDataModel>> getHeartRateData(
    DateTime start,
    DateTime end,
  ) async {
    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      return healthData
          .where((point) => point.type == HealthDataType.HEART_RATE)
          .map((point) => HealthDataModel.fromHealthDataPoint(point))
          .toList();
    } catch (e) {
      print('Error getting heart rate data: $e');
      return [];
    }
  }
}

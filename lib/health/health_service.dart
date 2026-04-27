import 'health_data_model.dart';
import 'health_repository.dart';
import 'health_permissions.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final HealthRepository _repository = HealthRepository();

  // Health data retrieval endpoints
  Future<List<HealthDataModel>> getData({
    DateTime? start,
    DateTime? end,
    HealthDataPeriod period = HealthDataPeriod.today,
  }) async {
    switch (period) {
      case HealthDataPeriod.today:
        return await _repository.getTodayData();
      case HealthDataPeriod.yesterday:
        return await _repository.getYesterdayData();
      case HealthDataPeriod.custom:
        if (start == null || end == null) {
          throw ArgumentError(
            'Start and end dates are required for custom period',
          );
        }
        return await _repository.getDataForPeriod(start, end);
      case HealthDataPeriod.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return await _repository.getDataForPeriod(startOfWeek, now);
      case HealthDataPeriod.thisMonth:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return await _repository.getDataForPeriod(startOfMonth, now);
    }
  }

  Future<HealthSummary> getSummary({
    DateTime? date,
    HealthDataPeriod period = HealthDataPeriod.today,
  }) async {
    switch (period) {
      case HealthDataPeriod.today:
        return await _repository.getTodaySummary();
      case HealthDataPeriod.yesterday:
        return await _repository.getYesterdaySummary();
      case HealthDataPeriod.custom:
        if (date == null) {
          throw ArgumentError('Date is required for custom period');
        }
        return await _repository.getSummaryForDate(date);
      default:
        return await _repository.getTodaySummary();
    }
  }

  Future<List<HealthSummary>> getWeeklySummary() async {
    return await _repository.getWeeklySummary();
  }

  // Specific data type endpoints
  Future<List<HealthDataModel>> getSteps({
    DateTime? start,
    DateTime? end,
    HealthDataPeriod period = HealthDataPeriod.today,
  }) async {
    final dates = _getPeriodDates(period, start, end);
    return await _repository.getStepsData(dates.start, dates.end);
  }

  Future<List<HealthDataModel>> getHeartRate({
    DateTime? start,
    DateTime? end,
    HealthDataPeriod period = HealthDataPeriod.today,
  }) async {
    final dates = _getPeriodDates(period, start, end);
    return await _repository.getHeartRateData(dates.start, dates.end);
  }

  // Health data writing endpoints
  Future<bool> writeSteps(int steps, {DateTime? start, DateTime? end}) async {
    start ??= DateTime.now().subtract(Duration(hours: 1));
    end ??= DateTime.now();
    return await _repository.writeSteps(steps, start, end);
  }

  Future<bool> writeWeight(double weight, {DateTime? dateTime}) async {
    dateTime ??= DateTime.now();
    return await _repository.writeWeight(weight, dateTime);
  }

  Future<bool> writeHeartRate(int heartRate, {DateTime? dateTime}) async {
    dateTime ??= DateTime.now();
    return await _repository.writeHeartRate(heartRate, dateTime);
  }

  // Permission management endpoints
  Future<bool> checkPermissions() async {
    return await HealthPermissions.checkPermissions();
  }

  Future<bool> requestPermissions() async {
    return await HealthPermissions.requestPermissions();
  }

  Future<bool> isHealthConnectInstalled() async {
    return await HealthPermissions.isHealthConnectInstalled();
  }

  // Helper methods
  ({DateTime start, DateTime end}) _getPeriodDates(
    HealthDataPeriod period,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    switch (period) {
      case HealthDataPeriod.today:
        return (
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case HealthDataPeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return (
          start: DateTime(yesterday.year, yesterday.month, yesterday.day),
          end: DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
            23,
            59,
            59,
          ),
        );
      case HealthDataPeriod.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return (start: startOfWeek, end: now);
      case HealthDataPeriod.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return (start: startOfMonth, end: now);
      case HealthDataPeriod.custom:
        if (customStart == null || customEnd == null) {
          throw ArgumentError('Custom start and end dates are required');
        }
        return (start: customStart, end: customEnd);
    }
  }
}

enum HealthDataPeriod { today, yesterday, thisWeek, thisMonth, custom }

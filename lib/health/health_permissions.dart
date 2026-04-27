import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class HealthPermissions {
  static final Health _health = Health();

  static const List<HealthDataType> _iosDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.SLEEP_ASLEEP,
    // HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  static const List<HealthDataType> _androidDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.TOTAL_CALORIES_BURNED,
    // HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  static List<HealthDataType> get _requiredDataTypes =>
      Platform.isIOS ? _iosDataTypes : _androidDataTypes;

  static Future<bool> checkPermissions() async {
    try {
      // On Android, verify Health Connect is installed first
      if (Platform.isAndroid) {
        bool isAvailable = await isHealthConnectInstalled();
        if (!isAvailable) {
          print('Health Connect not available');
          return false;
        }
      }
      bool? hasPermissions = await _health.hasPermissions(_requiredDataTypes);
      print('Has read permissions: $hasPermissions');
      return hasPermissions ?? false;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      // activityRecognition is Android-only; HealthKit on iOS does not use it
      if (Platform.isAndroid) {
        var activityStatus = await Permission.activityRecognition.request();
        if (activityStatus.isDenied) {
          print('Activity recognition permission denied');
          return false;
        }
      }

      bool authorized = await _health.requestAuthorization(
        _requiredDataTypes,
        permissions:
            _requiredDataTypes
                .map((type) => HealthDataAccess.READ_WRITE)
                .toList(),
      );
      return authorized;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> isHealthConnectInstalled() async {
    try {
      return await _health.isDataTypeAvailable(HealthDataType.STEPS);
    } catch (e) {
      print('Error checking Health Connect installation: $e');
      return false;
    }
  }

  static List<HealthDataType> get requiredDataTypes => _requiredDataTypes;

  static Future<bool> checkWritePermissions() async {
    try {
      bool? hasPermissions = await _health.hasPermissions(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.WRITE],
      );
      return hasPermissions ?? false;
    } catch (e) {
      print('Error checking write permissions: $e');
      return false;
    }
  }

  static Future<bool> requestWritePermissions() async {
    try {
      bool authorized = await _health.requestAuthorization(
        [
          HealthDataType.STEPS,
          HealthDataType.WEIGHT,
          HealthDataType.HEART_RATE,
        ],
        permissions: [
          HealthDataAccess.WRITE,
          HealthDataAccess.WRITE,
          HealthDataAccess.WRITE,
        ],
      );
      return authorized;
    } catch (e) {
      print('Error requesting write permissions: $e');
      return false;
    }
  }

  static Future<bool> writeTestData() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      bool success = true;

      // Write steps data
      success &= await _health.writeHealthData(
        value: 10000,
        type: HealthDataType.STEPS,
        startTime: yesterday,
        endTime: now,
      );

      // Write weight data
      success &= await _health.writeHealthData(
        value: 70.5,
        type: HealthDataType.WEIGHT,
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now,
      );

      // Write heart rate data
      success &= await _health.writeHealthData(
        value: 75,
        type: HealthDataType.HEART_RATE,
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.subtract(const Duration(minutes: 29)),
      );

      // DISTANCE_DELTA is Android-only; iOS uses DISTANCE_WALKING_RUNNING
      if (Platform.isAndroid) {
        success &= await _health.writeHealthData(
          value: 5000,
          type: HealthDataType.DISTANCE_DELTA,
          startTime: yesterday,
          endTime: now,
        );
      } else {
        success &= await _health.writeHealthData(
          value: 5000,
          type: HealthDataType.DISTANCE_WALKING_RUNNING,
          startTime: yesterday,
          endTime: now,
        );
      }
      return success;
    } catch (e) {
      print('Error writing test data: $e');
      return false;
    }
  }
}

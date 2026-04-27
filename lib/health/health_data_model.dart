import 'dart:ffi';

import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthDataModel {
  final HealthDataType type;
  final double value;
  final HealthDataUnit unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String sourceName;
  final String platform;
  final String? sourceDeviceId;
  final String? recordingMethod;
  final String? workoutActivityType;
  final double? totalEnergyBurned;
  final double? totalDistance;

  // final Map<String, dynamic>? metadata;

  HealthDataModel({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
    required this.sourceName,
    required this.platform,
    this.sourceDeviceId,
    this.recordingMethod,
    this.workoutActivityType,
    this.totalEnergyBurned,
    this.totalDistance,
    // this.metadata,
  });

  factory HealthDataModel.fromHealthDataPoint(HealthDataPoint point) {
    double value = 0.0;
    String? workoutActivityType;
    double? totalEnergyBurned;
    double? totalDistance;
    if (point.value is NumericHealthValue) {
      value = (point.value as NumericHealthValue).numericValue.toDouble();
    } else if (point.value is WorkoutHealthValue) {
      final w = point.value as WorkoutHealthValue;
      workoutActivityType = w.workoutActivityType.name;
      totalEnergyBurned = w.totalEnergyBurned?.toDouble();
      totalDistance = w.totalDistance?.toDouble();
      // optional: use energy burned as "value" for display purposes
      value = totalEnergyBurned ?? 0.0;
    }

    return HealthDataModel(
      type: point.type,
      value: value,
      unit: point.unit,
      dateFrom: point.dateFrom,
      dateTo: point.dateTo,
      sourceName: point.sourceName,
      platform: point.sourcePlatform.name,
      sourceDeviceId: point.sourceDeviceId,
      recordingMethod: point.recordingMethod.name,
      workoutActivityType: workoutActivityType,
      totalEnergyBurned: totalEnergyBurned,
      totalDistance: totalDistance,
      // metadata: point.metadata,
    );
  }

  String get displayValue {
    if (workoutActivityType != null) {
      return '$workoutActivityType - '
          '${totalEnergyBurned?.toInt() ?? 0} kcal, '
          '${(totalDistance ?? 0) / 1000.0} km';
    }
    switch (type) {
      case HealthDataType.STEPS:
        return '${value.toInt()} steps';
      case HealthDataType.HEART_RATE:
        return '${value.toInt()} BPM';
      case HealthDataType.WEIGHT:
        return '${value.toStringAsFixed(1)} kg';
      case HealthDataType.HEIGHT:
        return '${value.toStringAsFixed(1)} cm';
      case HealthDataType.SLEEP_ASLEEP:
        return '${(value / 60).toStringAsFixed(1)} hours';
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return '${(value / 1000).toStringAsFixed(2)} km';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return '${value.toInt()} calories';
      case HealthDataType.SLEEP_DEEP:
        return '${value.toInt()} minutes';
      case HealthDataType.SLEEP_LIGHT:
        return '${value.toInt()} minutes';
      case HealthDataType.SLEEP_REM:
        return '${value.toInt()} minutes';
      case HealthDataType.EXERCISE_TIME:
        return '${value.toInt()} minutes';
      case HealthDataType.ACTIVE_ENERGY_BURNED:                           //Replace with 'APPLE_STAND_TIME' for ios:
        return '${value.toDouble()} hours';
      case HealthDataType.EXERCISE_TIME:                                  //Replace with 'APPLE_MOVE_TIME' for ios
        return '${value.toInt()} seconds';
      case HealthDataType.EXERCISE_TIME:
        return '${value.toInt()} minutes';
      case HealthDataType.TOTAL_CALORIES_BURNED:
        return '${value.toInt()} calories';
      default:
        return '${value.toStringAsFixed(1)} ${unit.name}';
    }
  }

  String get displayName {
    if (workoutActivityType != null) {
      return 'Workout: $workoutActivityType';
    }
    switch (type) {
      case HealthDataType.STEPS:
        return 'Steps';
      case HealthDataType.HEART_RATE:
        return 'Heart Rate';
      case HealthDataType.WEIGHT:
        return 'Weight';
      case HealthDataType.HEIGHT:
        return 'Height';
      case HealthDataType.SLEEP_ASLEEP:
        return 'Sleep Time';
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return 'Walking/Running Distance';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return 'Calories';
      default:
        return type.name;
    }
  }
}

class HealthSummary {
  final int totalSteps;
  final double totalDistance;
  final int totalCalories;
  final int averageHeartRate;
  final double sleepHours;
  final DateTime date;
  final int? exerciseMinutes;
  final int? sedentaryMinutes;
  final int? activeMinutes;
  final int? maxHeartRate;
  final int? sleep_deep_minutes;
  final int? sleep_light_minutes;
  final int? sleep_rem_minutes;
  final int? totalEnergyBurned;

  HealthSummary({
    required this.totalSteps,
    required this.totalDistance,
    required this.totalCalories,
    required this.averageHeartRate,
    required this.sleepHours,
    required this.date,
    this.exerciseMinutes,
    this.sedentaryMinutes,
    this.activeMinutes,
    this.maxHeartRate,
    this.sleep_deep_minutes,
    this.sleep_light_minutes,
    this.sleep_rem_minutes,
    this.totalEnergyBurned,
  });

  factory HealthSummary.fromHealthData(
      List<HealthDataModel> data,
      DateTime date,
      ) {
    int steps = 0;
    double distance = 0;
    int calories = 0;
    int heartRateSum = 0;
    int heartRateCount = 0;
    double sleep = 0;
    int maxHeartRate = 0;
    int sleepDeepMinutes = 0;
    int sleepLightMinutes = 0;
    int sleepRemMinutes = 0;
    int exerciseMinutes = 0;
    int totalCaloriesBurned = 0;

    for (final item in data) {
      switch (item.type) {
        case HealthDataType.STEPS:
          steps += item.value.toInt();
          break;
        case HealthDataType.DISTANCE_WALKING_RUNNING:
        case HealthDataType.DISTANCE_DELTA:
          distance += item.value;
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          calories += item.value.toInt();
          break;
        case HealthDataType.TOTAL_CALORIES_BURNED:
          totalCaloriesBurned += item.value.toInt();
          break;
        case HealthDataType.HEART_RATE:
          final hr = item.value.toInt();
          heartRateSum += hr;
          heartRateCount++;
          if (hr > maxHeartRate) maxHeartRate = hr;
          break;
        case HealthDataType.SLEEP_ASLEEP:
          sleep += item.value / 60.0;
          break;
        case HealthDataType.SLEEP_DEEP:
          sleepDeepMinutes += item.value.toInt();
          break;
        case HealthDataType.SLEEP_LIGHT:
          sleepLightMinutes += item.value.toInt();
          break;
        case HealthDataType.SLEEP_REM:
          sleepRemMinutes += item.value.toInt();
          break;
        case HealthDataType.EXERCISE_TIME:
          exerciseMinutes += item.value.toInt();
          break;
        default:
          break;
      }
    }

    return HealthSummary(
      totalSteps: steps,
      totalDistance: distance / 1000.0,
      totalCalories: calories > 0 ? calories : totalCaloriesBurned,
      averageHeartRate: heartRateCount > 0
          ? (heartRateSum / heartRateCount).round()
          : 0,
      sleepHours: sleep > 0
          ? sleep
          : (sleepDeepMinutes + sleepLightMinutes + sleepRemMinutes) / 60.0,
      date: date,
      exerciseMinutes: exerciseMinutes,
      activeMinutes: exerciseMinutes,
      sedentaryMinutes: null,
      maxHeartRate: maxHeartRate,
      sleep_deep_minutes: sleepDeepMinutes,
      sleep_light_minutes: sleepLightMinutes,
      sleep_rem_minutes: sleepRemMinutes,
    );
  }

  Map<String, dynamic> toMap({required int? userId}) {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T').first,
      'total_steps': totalSteps,
      'total_distance': totalDistance,
      'total_calories': totalCalories,
      'average_heart_rate': averageHeartRate,
      'sleep_hours': sleepHours,
      'exercise_minutes': exerciseMinutes,
      'sedentary_minutes': sedentaryMinutes,
      'active_minutes': activeMinutes,
      'max_heart_rate': maxHeartRate,
      'sleep_deep_minutes': sleep_deep_minutes,
      'sleep_light_minutes': sleep_light_minutes,
      'sleep_rem_minutes': sleep_rem_minutes,
    };
  }
}

class UserProfile {
  final String userId;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? gender;
  final double? weight;
  final String? weightUnit;
  final double? height;
  final String? heightUnit;
  final int? age;
  final double? restingHeartRate;
  final int? predictedHeartRate;
  final String? userGoal;

  UserProfile({
    required this.userId,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phoneNumber,
    this.gender,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
    this.age,
    this.restingHeartRate,
    this.predictedHeartRate,
    this.userGoal,
  });
}

class DetailedSleepData {
  final DateTime date;
  final int? totalSleepMinutes;
  final int? awakeMinutes;
  final int? deepMinutes;
  final int? lightMinutes;
  final int? sedentarySleepMinutes;
  final int? activeSleepMinutes;
  final double? averageBpm;

  DetailedSleepData({
    required this.date,
    this.totalSleepMinutes,
    this.awakeMinutes,
    this.deepMinutes,
    this.lightMinutes,
    this.sedentarySleepMinutes,
    this.activeSleepMinutes,
    this.averageBpm,
  });

  double get totalSleepHours => (totalSleepMinutes ?? 0) / 60.0;
  double get sleepEfficiency =>
      totalSleepMinutes != null && awakeMinutes != null
          ? (totalSleepMinutes! / (totalSleepMinutes! + awakeMinutes!)) * 100
          : 0.0;
}

class WorkoutSession {
  final String workoutId;
  final String? workoutName;
  final DateTime workoutDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? durationMinutes;
  final int? caloriesBurned;
  final double? averageBpm;
  final double? maxBpm;
  final double? distance;

  WorkoutSession({
    required this.workoutId,
    this.workoutName,
    required this.workoutDate,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.caloriesBurned,
    this.averageBpm,
    this.maxBpm,
    this.distance,
  });

  factory WorkoutSession.fromHealthDataPoints(
    HealthDataModel workoutPoint,
    List<HealthDataModel> heartRatePoints,
    DateTime date,
  ) {
    if (workoutPoint.workoutActivityType == null) {
      throw ArgumentError("Provided point is not a workout");
    }

    // filter heartRatePoints inside workout duration
    final hrInRange =
        heartRatePoints
            .where((p) {
              return p.dateFrom.isAfter(workoutPoint.dateFrom) &&
                  p.dateTo.isBefore(workoutPoint.dateTo);
            })
            .map((p) => p.value as double)
            .toList();

    double? avgHr;
    double? maxHr;
    if (hrInRange.isNotEmpty) {
      avgHr = hrInRange.reduce((a, b) => a + b) / hrInRange.length;
      maxHr = hrInRange.reduce((a, b) => a > b ? a : b).toDouble();
    }

    return WorkoutSession(
      workoutId:
          "${workoutPoint.type.name}_${workoutPoint.dateFrom.toIso8601String()}",
      workoutName: workoutPoint.workoutActivityType,
      workoutDate: date,
      startTime: workoutPoint.dateFrom,
      endTime: workoutPoint.dateTo,
      durationMinutes:
          workoutPoint.dateTo
              .difference(workoutPoint.dateFrom)
              .inMinutes
              .toDouble(),
      caloriesBurned: workoutPoint.totalEnergyBurned?.toInt(),
      distance: (workoutPoint.totalDistance ?? 0) / 1000.toDouble(),
      averageBpm: avgHr,
      maxBpm: maxHr,
    );
  }

  Map<String, dynamic> toMap({required int? userId}) {
    return {
      'user_id': userId,
      'workout_session_fact_id': workoutId,
      'workout_name': workoutName,
      'workout_date': workoutDate.toIso8601String().split('T').first,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_min': durationMinutes?.toDouble(),
      'calories_burned': caloriesBurned?.toInt(),
      'avg_bpm': averageBpm?.toDouble(),
      'max_bpm': maxBpm?.toDouble(),
      'distance': distance?.toDouble(),
    };
  }
}

class ExerciseLog {
  final String exerciseName;
  final String? targetArea;
  final String? description;
  final String? equipment;
  final DateTime logDate;
  final DateTime? logTime;
  final double? caloriesBurned;
  final List<ExerciseSet>? sets;

  ExerciseLog({
    required this.exerciseName,
    this.targetArea,
    this.description,
    this.equipment,
    required this.logDate,
    this.logTime,
    this.caloriesBurned,
    this.sets,
  });
}

class ExerciseSet {
  final int setNumber;
  final int? reps;
  final double? weight;
  final String? weightUnit;
  final double? duration;
  final double? distance;

  ExerciseSet({
    required this.setNumber,
    this.reps,
    this.weight,
    this.weightUnit,
    this.duration,
    this.distance,
  });
}

class DetailedHeartRateData {
  final double heartRate;
  final String unit;
  final DateTime timeFrom;
  final DateTime timeTo;
  final String sourcePlatform;
  final String? sourceDeviceId;
  final String sourceName;
  final String? recordingMethod;

  DetailedHeartRateData({
    required this.heartRate,
    required this.unit,
    required this.timeFrom,
    required this.timeTo,
    required this.sourcePlatform,
    this.sourceDeviceId,
    required this.sourceName,
    this.recordingMethod,
  });
}

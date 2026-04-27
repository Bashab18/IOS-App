import 'package:health/health.dart';

/// Enhanced health data types based on mHealth database structure
class HealthParameters {
  // Core health data types from original framework
  static const List<HealthDataType> basicHealthTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  // Additional health data types for enhanced mHealth functionality
  static const List<HealthDataType> enhancedHealthTypes = [
    // Energy and Activity
    HealthDataType.BASAL_ENERGY_BURNED,

    // Sleep Details
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_IN_BED,

    // Heart Rate Variability
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    // HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.RESTING_HEART_RATE,

    // Activity and Movement
    // HealthDataType.MOVE_MINUTES,
    HealthDataType.EXERCISE_TIME,
    // HealthDataType.STAND_TIME,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.DISTANCE_CYCLING,
    HealthDataType.DISTANCE_SWIMMING,

    // Workout and Exercise

    // HealthDataType.STRENGTH_TRAINING_SESSION,
    // HealthDataType.SWIMMING_SESSION,
    // HealthDataType.CYCLING_SESSION,
    // HealthDataType.RUNNING_SESSION,

    // Body Measurements
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.WAIST_CIRCUMFERENCE,
    // HealthDataType.LEAN_BODY_MASS,

    // Vitals
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.RESPIRATORY_RATE,

    // Nutrition (if available)
    HealthDataType.WATER,
    // HealthDataType.PROTEIN,
    // HealthDataType.CARBS,
    // HealthDataType.FAT,
    // HealthDataType.FIBER,
    // HealthDataType.SUGAR,
    // HealthDataType.SODIUM,

    // Mental Health and Mindfulness
    HealthDataType.MINDFULNESS,

    // Women's Health
    // HealthDataType.MENSTRUATION_FLOW,

    // Environmental
    // HealthDataType.UV_EXPOSURE,
  ];

  // All health data types combined
  static List<HealthDataType> get allHealthTypes => [
    ...basicHealthTypes,
    // ...enhancedHealthTypes,
  ];

  // Permissions required for basic functionality
  static List<HealthDataAccess> get basicPermissions =>
      basicHealthTypes.map((type) => HealthDataAccess.READ_WRITE).toList();

  // Permissions required for enhanced functionality
  // static List<HealthDataAccess> get enhancedPermissions => enhancedHealthTypes
  //     .map((type) => HealthDataAccess.READ_WRITE)
  //     .toList();

  // All permissions combined
  static List<HealthDataAccess> get allPermissions =>
      allHealthTypes.map((type) => HealthDataAccess.READ_WRITE).toList();

  // Priority data types for initial setup
  static const List<HealthDataType> priorityHealthTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.WEIGHT,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.DISTANCE_DELTA,
    // HealthDataType.MOVE_MINUTES,
  ];

  // Data types for activity tracking (matching mHealth daily_activity_fact)
  static const List<HealthDataType> activityTrackingTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
    // HealthDataType.MOVE_MINUTES,
    HealthDataType.HEART_RATE,
    // HealthDataType.STAND_TIME,
  ];

  // Data types for sleep analysis (matching mHealth daily_sleep_fact)
  static const List<HealthDataType> sleepAnalysisTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.HEART_RATE, // for sleep BPM
  ];

  // Data types for workout sessions (matching mHealth workout_session_fact)
  static const List<HealthDataType> workoutSessionTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.DISTANCE_CYCLING,
    HealthDataType.DISTANCE_SWIMMING,
    HealthDataType.EXERCISE_TIME,
  ];

  // User profile related types (matching mHealth user_dim)
  static const List<HealthDataType> userProfileTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.RESTING_HEART_RATE,
  ];

  // Check if a health data type is available on the current platform
  static bool isTypeSupported(HealthDataType type) {
    // This would need to be implemented based on platform-specific availability
    // For now, return true for common types
    return basicHealthTypes.contains(type) ||
        enhancedHealthTypes.contains(type);
  }

  // Get display name for health data type
  static String getDisplayName(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'Steps';
      case HealthDataType.HEART_RATE:
        return 'Heart Rate';
      case HealthDataType.RESTING_HEART_RATE:
        return 'Resting Heart Rate';
      case HealthDataType.WEIGHT:
        return 'Weight';
      case HealthDataType.HEIGHT:
        return 'Height';
      case HealthDataType.SLEEP_ASLEEP:
        return 'Sleep Time';
      case HealthDataType.SLEEP_DEEP:
        return 'Deep Sleep';
      case HealthDataType.SLEEP_LIGHT:
        return 'Light Sleep';
      case HealthDataType.SLEEP_REM:
        return 'REM Sleep';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return 'Active Calories';
      case HealthDataType.BASAL_ENERGY_BURNED:
        return 'Basal Calories';
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return 'Walking/Running Distance';
      case HealthDataType.EXERCISE_TIME:
        return 'Exercise Time';
      // case HealthDataType.MOVE_MINUTES:
      //   return 'Move Minutes';
      // case HealthDataType.STAND_TIME:
      //   return 'Stand Time';
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return 'Body Fat %';
      case HealthDataType.BODY_MASS_INDEX:
        return 'BMI';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        return 'Systolic BP';
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'Diastolic BP';
      case HealthDataType.BLOOD_OXYGEN:
        return 'Blood Oxygen';
      case HealthDataType.WATER:
        return 'Water Intake';
      default:
        return type.name.replaceAll('_', ' ').toLowerCase();
    }
  }
}

/// Categories for organizing health data
enum HealthDataCategory {
  activity,
  sleep,
  heartRate,
  body,
  nutrition,
  workouts,
  vitals,
  mentalHealth,
}

extension HealthDataCategoryExtension on HealthDataCategory {
  String get displayName {
    switch (this) {
      case HealthDataCategory.activity:
        return 'Activity';
      case HealthDataCategory.sleep:
        return 'Sleep';
      case HealthDataCategory.heartRate:
        return 'Heart Rate';
      case HealthDataCategory.body:
        return 'Body Measurements';
      case HealthDataCategory.nutrition:
        return 'Nutrition';
      case HealthDataCategory.workouts:
        return 'Workouts';
      case HealthDataCategory.vitals:
        return 'Vitals';
      case HealthDataCategory.mentalHealth:
        return 'Mental Health';
    }
  }

  List<HealthDataType> get dataTypes {
    switch (this) {
      case HealthDataCategory.activity:
        return HealthParameters.activityTrackingTypes;
      case HealthDataCategory.sleep:
        return HealthParameters.sleepAnalysisTypes;
      case HealthDataCategory.heartRate:
        return [
          HealthDataType.HEART_RATE,
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.HEART_RATE_VARIABILITY_SDNN,
          // HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
        ];
      case HealthDataCategory.body:
        return HealthParameters.userProfileTypes;
      case HealthDataCategory.nutrition:
        return [
          HealthDataType.WATER,
          // HealthDataType.PROTEIN,
          // HealthDataType.CARBS,
          // HealthDataType.FAT,
          // HealthDataType.FIBER,
          // HealthDataType.SUGAR,
          // HealthDataType.SODIUM,
        ];
      case HealthDataCategory.workouts:
        return HealthParameters.workoutSessionTypes;
      case HealthDataCategory.vitals:
        return [
          HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          HealthDataType.BLOOD_OXYGEN,
          HealthDataType.BODY_TEMPERATURE,
          HealthDataType.RESPIRATORY_RATE,
        ];
      case HealthDataCategory.mentalHealth:
        return [HealthDataType.MINDFULNESS];
    }
  }
}

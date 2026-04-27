class WorkoutLog {
  final int? id;
  final int workoutRoutineFactId;
  final int userDimId;
  final String logDate;
  final int logDuration;
  final double? caloriesBurned;
  final String routineName;

  WorkoutLog({
    this.id,
    required this.workoutRoutineFactId,
    required this.userDimId,
    required this.logDate,
    required this.logDuration,
    this.caloriesBurned,
    required this.routineName
  });

  /// Convert WorkoutLog to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'log_workout_fact_id': id,
      'workout_routine_fact_id': workoutRoutineFactId,
      'user_dim_id': userDimId,
      'log_date': logDate,
      'log_duration': logDuration,
      'calories_burned': caloriesBurned,
      'routine_name': routineName,
    };
  }

  /// Create WorkoutLog from Map (from database)
  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['log_workout_fact_id']?.toInt(),
      workoutRoutineFactId: map['workout_routine_fact_id']?.toInt() ?? 0,
      userDimId: map['user_dim_id']?.toInt() ?? 0,
      logDate: map['log_date'] ?? '',
      logDuration: map['log_duration']?.toInt() ?? 0,
      caloriesBurned: map['calories_burned']?.toDouble(),
      routineName: map['routine_name'] ?? '',
    );
  }

  /// Create a copy with updated fields
  WorkoutLog copyWith({
    int? id,
    int? workoutRoutineFactId,
    int? userDimId,
    String? logDate,
    int? logDuration,
    double? caloriesBurned,
    String? routineName,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      workoutRoutineFactId: workoutRoutineFactId ?? this.workoutRoutineFactId,
      userDimId: userDimId ?? this.userDimId,
      logDate: logDate ?? this.logDate,
      logDuration: logDuration ?? this.logDuration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      routineName: routineName ?? this.routineName,
    );
  }

  /// Get formatted date (MM/dd/yy)
  String get formattedDate {
    if (logDate.isEmpty) return '';
    
    try {
      final date = DateTime.parse(logDate);
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
    } catch (e) {
      return logDate;
    }
  }

  /// Get duration as formatted string
  String get formattedDuration {
    final hours = logDuration! ~/ 60;
    final minutes = logDuration! % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }


  /// Get calories as formatted string
  String get formattedCalories {
    if (caloriesBurned == null) return 'N/A';
    return caloriesBurned!.toInt().toString();
  }

  @override
  String toString() {
    return 'WorkoutLog{id: $id, routineName: $routineName, logDate: $logDate, logDuration: $logDuration, calories: $caloriesBurned}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WorkoutLog &&
        other.id == id &&
        other.workoutRoutineFactId == workoutRoutineFactId &&
        other.userDimId == userDimId &&
        other.logDate == logDate &&
        other.logDuration == logDuration &&
        other.caloriesBurned == caloriesBurned &&
        other.routineName == routineName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      workoutRoutineFactId,
      userDimId,
      logDate,
      logDuration,
      caloriesBurned,
      routineName,
    );
  }
}
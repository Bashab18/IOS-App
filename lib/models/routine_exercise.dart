class RoutineExercise {
  final int? id;
  final int workoutRoutineFactId;
  final int? exerciseLibraryDimId;  // For predefined exercises
  final int? userExerciseDimId;     // For custom exercises
  final int repetitions;
  final int sets;
  final int weight;
  final String weightUnit;
  
  // Additional info for display (not stored in this table)
  final String? exerciseName;
  final String? targetArea;

  RoutineExercise({
    this.id,
    required this.workoutRoutineFactId,
    this.exerciseLibraryDimId,
    this.userExerciseDimId,
    required this.repetitions,
    required this.sets,
    required this.weight,
    required this.weightUnit,
    this.exerciseName,
    this.targetArea,
  });

  Map<String, dynamic> toMap() => {
    'workout_routine_fact_id': workoutRoutineFactId,
    'exercise_library_dim_id': exerciseLibraryDimId,
    'user_exercise_dim_id': userExerciseDimId,
    'repetitions': repetitions,
    'sets': sets,
    'weight': weight,
    'weight_unit': weightUnit,
  };

  factory RoutineExercise.fromMap(Map<String, dynamic> map) => RoutineExercise(
    id: map['routine_exercise_fact_id'],
    workoutRoutineFactId: map['workout_routine_fact_id'] ?? 0,
    exerciseLibraryDimId: map['exercise_library_dim_id'],
    userExerciseDimId: map['user_exercise_dim_id'],
    repetitions: map['repetitions'] ?? 0,
    sets: map['sets'] ?? 0,
    weight: map['weight'] ?? 0,
    weightUnit: map['weight_unit'] ?? 'lbs',
    exerciseName: map['exercise_name'],
    targetArea: map['target_area'],
  );

  bool get isLibraryExercise => exerciseLibraryDimId != null;
  bool get isCustomExercise => userExerciseDimId != null;
}
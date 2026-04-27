class WorkoutRoutine {
  final int? id;
  final int userDimId;
  final String workoutRoutineName;
  final String createdAt;
  final bool isAiGenerated;

  WorkoutRoutine({
    this.id,
    required this.userDimId,
    required this.workoutRoutineName,
    required this.createdAt,
    this.isAiGenerated = false,
  });

  Map<String, dynamic> toMap() => {
    'user_dim_id': userDimId,
    'workout_routine_name': workoutRoutineName,
    'created_at': createdAt,
    'is_ai_generated': isAiGenerated ? 1 : 0,
  };

  factory WorkoutRoutine.fromMap(Map<String, dynamic> map) => WorkoutRoutine(
    id: map['workout_routine_fact_id'],
    userDimId: map['user_dim_id'] ?? 0,
    workoutRoutineName: map['workout_routine_name'] ?? '',
    createdAt: map['created_at'] ?? '',
    isAiGenerated: (map['is_ai_generated'] ?? 0) == 1,
  );
}
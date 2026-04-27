class ExerciseLibrary {
  final int? id;
  final String exerciseName;
  final String targetArea;
  final String? description;
  final String? equipment;
  final String? instructions;
  final String? warning;
  final String? photoPosition;

  ExerciseLibrary({
    this.id,
    required this.exerciseName,
    required this.targetArea,
    this.description,
    this.equipment,
    this.instructions,
    this.warning,
    this.photoPosition,
  });

  Map<String, dynamic> toMap() => {
    'exercise_name': exerciseName,
    'target_area': targetArea,
    'description': description,
    'equipment': equipment,
    'instructions': instructions,
    'warning': warning,
    'photo_position': photoPosition,
  };

  factory ExerciseLibrary.fromMap(Map<String, dynamic> map) => ExerciseLibrary(
    id: map['exercise_library_dim_id'],
    exerciseName: map['exercise_name'] ?? '',
    targetArea: map['target_area'] ?? '',
    description: map['description'],
    equipment: map['equipment'],
    instructions: map['instructions'],
    warning: map['warning'],
    photoPosition: map['photo_position'],
  );

  @override
  String toString() => 'ExerciseLibrary(id: $id, name: $exerciseName, targetArea: $targetArea)';
}
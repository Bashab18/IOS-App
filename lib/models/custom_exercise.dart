class CustomExercise {
  final int? id;
  final int userDimId;
  final String dateCreated;
  final String exerciseName;
  final List<String> targetArea;
  final String? description;
  final String? equipment;
  final String? instructions;
  final String? warning;
  final String? photoPath; // Local file path for uploaded photo
  final String? photoUrl; // Optional URL for cloud storage

  CustomExercise({
    this.id,
    required this.userDimId,
    required this.dateCreated,
    required this.exerciseName,
    required this.targetArea,
    this.description,
    this.equipment,
    this.instructions,
    this.warning,
    this.photoPath,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'user_dim_id': userDimId,
    'date_created': dateCreated,
    'exercise_name': exerciseName,
    'target_area': targetArea.join(','),
    'description': description,
    'equipment': equipment,
    'instructions': instructions,
    'warning': warning,
    'photo_path': photoPath,
    'photo_url': photoUrl,
  };

  factory CustomExercise.fromMap(Map<String, dynamic> map) => CustomExercise(
    id: map['user_exercise_dim_id'],
    userDimId: map['user_dim_id'] ?? 0,
    dateCreated: map['date_created'] ?? '',
    exerciseName: map['exercise_name'] ?? '',
    targetArea: _parseTargetArea(
      map['target_area'],
    ), // Fixed: Parse back to List
    description: map['description'],
    equipment: map['equipment'],
    instructions: map['instructions'],
    warning: map['warning'],
    photoPath: map['photo_path'],
    photoUrl: map['photo_url'],
  );

  static List<String> _parseTargetArea(dynamic targetArea) {
    if (targetArea == null) return [];
    if (targetArea is String) {
      return targetArea.isEmpty
          ? []
          : targetArea.split(',').map((e) => e.trim()).toList();
    }
    if (targetArea is List) {
      return targetArea.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Create a copy with modified fields (useful for editing)
  CustomExercise copyWith({
    int? id,
    int? userDimId,
    String? dateCreated,
    String? exerciseName,
    List<String>? targetArea, // Fixed: Correct type
    String? description,
    String? equipment,
    String? instructions,
    String? warning,
    String? photoPath,
    String? photoUrl,
  }) => CustomExercise(
    id: id ?? this.id,
    userDimId: userDimId ?? this.userDimId,
    dateCreated: dateCreated ?? this.dateCreated,
    exerciseName: exerciseName ?? this.exerciseName,
    targetArea: targetArea ?? this.targetArea,
    description: description ?? this.description,
    equipment: equipment ?? this.equipment,
    instructions: instructions ?? this.instructions,
    warning: warning ?? this.warning,
    photoPath: photoPath ?? this.photoPath,
    photoUrl: photoUrl ?? this.photoUrl,
  );

  // Helper method to get the best available photo source
  String? get bestPhotoSource => photoUrl ?? photoPath;

  // Helper method to check if exercise has a photo
  bool get hasPhoto => photoPath != null || photoUrl != null;

  @override
  String toString() =>
      'CustomExercise(id: $id, name: $exerciseName, targetArea: $targetArea)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomExercise &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              exerciseName == other.exerciseName;

  @override
  int get hashCode => id.hashCode ^ exerciseName.hashCode;
}

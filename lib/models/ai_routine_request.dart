import 'dart:convert';

class AIRoutineRequest {
  final int? id;
  final int userId;
  final List<String> targetAreas;
  final int? durationMinutes;
  final String? intensity;
  final List<String> goals;
  final String? customGoals;
  final List<String> healthConditions;
  final String? fitnessLevel;
  final String? additionalComments;
  final String status;
  final int? generatedRoutineId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AIRoutineRequest({
    this.id,
    required this.userId,
    required this.targetAreas,
    this.durationMinutes,
    this.intensity,
    required this.goals,
    this.customGoals,
    required this.healthConditions,
    this.fitnessLevel,
    this.additionalComments,
    this.status = 'pending',
    this.generatedRoutineId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_areas': jsonEncode(targetAreas),
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'goals': jsonEncode(goals),
      'custom_goals': customGoals,
      'health_conditions': jsonEncode(healthConditions),
      'fitness_level': fitnessLevel,
      'additional_comments': additionalComments,
      'status': status,
      'generated_routine_id': generatedRoutineId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AIRoutineRequest.fromMap(Map<String, dynamic> map) {
    return AIRoutineRequest(
      id: map['id'],
      userId: map['user_id'],
      targetAreas: List<String>.from(jsonDecode(map['target_areas'] ?? '[]')),
      durationMinutes: map['duration_minutes'],
      intensity: map['intensity'],
      goals: List<String>.from(jsonDecode(map['goals'] ?? '[]')),
      customGoals: map['custom_goals'],
      healthConditions: List<String>.from(jsonDecode(map['health_conditions'] ?? '[]')),
      fitnessLevel: map['fitness_level'],
      additionalComments: map['additional_comments'],
      status: map['status'] ?? 'pending',
      generatedRoutineId: map['generated_routine_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
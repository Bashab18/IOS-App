class Exercise {
  final String name;
  final String videoUrl;
  final String category1;
  final String category2;
  final String category3;
  final String Audience;
  final String Accessory_1;
  final String What_to_do;
  final String accessory2;
  final String accessory3;
  final String repetitions;
  final String musclesInvolved;
  final String heuristicLevel;
  final String acsmLevel;

  Exercise({
    required this.name,
    required this.videoUrl,
    required this.category1,
    required this.category2,
    required this.category3,
    required this.Audience,
    required this.Accessory_1,
    required this.What_to_do,
    required this.accessory2,
    required this.accessory3,
    required this.repetitions,
    required this.musclesInvolved,
    required this.heuristicLevel,
    required this.acsmLevel,
  });

  /// Build from a header->value map (safer than numeric indexes).
  factory Exercise.fromMap(Map<String, String> m) {
    String norm(String? s) => _normalize(s ?? '');
    return Exercise(
      name:       norm(m['Name']),
      videoUrl:   norm(m['Video Link']),
      category1:  norm(m['Category 1']),
      category2:  norm(m['Category 2']),
      category3:  norm(m['Category 3']),
      Audience:   norm(m['Audience']),
      Accessory_1 :  norm(m['Accessory 1']),
      What_to_do:      norm(m['What to Do']),
      accessory2: norm(m['Accessory 2']),
      accessory3: norm(m['Accessory 3']),
      repetitions: norm(m['Repetitions']),
      musclesInvolved: norm(m['Muscles Involved']),
      heuristicLevel: norm(m['Heuristic Level']),
      acsmLevel: norm(m['ACSM Level']),
    );
  }
}

/// Aggressive normalization to kill invisible chars and spaces.
String _normalize(String s) {
  // Remove BOM, zero-width spaces, CR, tabs; collapse whitespace.
  final cleaned = s
      .replaceAll('\uFEFF', '')     // BOM
      .replaceAll('\u200B', '')     // zero-width space
      .replaceAll('\r', '')         // CR
      .replaceAll('\t', ' ')
      .trim();
  return cleaned;
}

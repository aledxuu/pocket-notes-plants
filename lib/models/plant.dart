class Plant {
  final int? id; // null until the database assigns one (AUTOINCREMENT)
  final String plantName;
  final String wateringNotes;

  Plant({
    this.id,
    required this.plantName,
    required this.wateringNotes,
  });

  // Plant object -> Map (to save into SQLite)
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'plant_name': plantName,
      'watering_notes': wateringNotes,
    };
  }

  // Map (a database row) -> Plant object
  factory Plant.fromMap(Map<String, Object?> map) {
    return Plant(
      id: map['id'] as int?,
      plantName: map['plant_name'] as String,
      wateringNotes: map['watering_notes'] as String,
    );
  }
}

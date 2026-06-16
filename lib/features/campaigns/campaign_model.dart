class Campaign {
  final int? id;
  final String name;
  final String system;
  final String nextSession;
  final String notes;

  Campaign({
    this.id,
    required this.name,
    required this.system,
    required this.nextSession,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'system': system,
      'next_session': nextSession,
      'notes': notes,
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as int?,
      name: map['name'] as String,
      system: map['system'] as String,
      nextSession: map['next_session'] as String,
      notes: map['notes'] as String? ?? '',
    );
  }

  Campaign copyWith({
    int? id,
    String? name,
    String? system,
    String? nextSession,
    String? notes,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      system: system ?? this.system,
      nextSession: nextSession ?? this.nextSession,
      notes: notes ?? this.notes,
    );
  }
}

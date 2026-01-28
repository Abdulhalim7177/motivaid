/// Unit model - Department/unit within a facility
class Unit {
  final String id;
  final String facilityId;
  final String name;
  final String? description;
  final int? capacity;
  final String? specialization;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Unit({
    required this.id,
    required this.facilityId,
    required this.name,
    this.description,
    this.capacity,
    this.specialization,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      facilityId: json['facility_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int?,
      specialization: json['specialization'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facility_id': facilityId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'specialization': specialization,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  Unit copyWith({
    String? id,
    String? facilityId,
    String? name,
    String? description,
    int? capacity,
    String? specialization,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      specialization: specialization ?? this.specialization,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Unit(id: $id, name: $name, facilityId: $facilityId)';
}

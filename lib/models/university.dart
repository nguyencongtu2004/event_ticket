class University {
  final String? id;
  final String? name;
  final List<Faculty>? faculties;

  University({
    required this.id,
    required this.name,
    required this.faculties,
  });

  factory University.fromNull() =>
      University(id: null, name: null, faculties: null);

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['_id'],
      name: json['name'],
      faculties: json['faculties'] == null
          ? null
          : (json['faculties'] as List)
              .map((faculty) => Faculty.fromJson(faculty))
              .toList(),
    );
  }

  @override
  String toString() => 'University(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is University && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Faculty {
  final String? id;
  final String? name;
  final List<Major>? majors;

  Faculty({
    required this.id,
    required this.name,
    required this.majors,
  });

  factory Faculty.fromNull() => Faculty(id: null, name: null, majors: null);

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['_id'],
      name: json['name'],
      majors: json['majors'] == null
          ? null
          : (json['majors'] as List)
              .map((major) => Major.fromJson(major))
              .toList(),
    );
  }

  @override
  String toString() => 'Faculty(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Faculty && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Major {
  final String? id;
  final String? name;

  Major({
    required this.id,
    required this.name,
  });

  factory Major.fromNull() => Major(id: null, name: null);

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: json['_id'],
      name: json['name'],
    );
  }

  @override
  String toString() => 'Major(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Major && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

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
      faculties: (json['faculties'] as List)
          .map((faculty) => Faculty.fromJson(faculty))
          .toList(),
    );
  }
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
      majors: (json['majors'] as List)
          .map((major) => Major.fromJson(major))
          .toList(),
    );
  }
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
}

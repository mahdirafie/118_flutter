part of 'filter_bloc.dart';

class Faculty extends Equatable {
  final int id;
  final String name;

  const Faculty({required this.id, required this.name});

  // Add factory constructor from FacultyModel
  factory Faculty.fromModel(FacultyModel model) {
    return Faculty(id: model.fid, name: model.fname);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Faculty.fromJson(Map<String, dynamic> json) =>
      Faculty(id: json['id'] as int, name: json['name'] as String);

  @override
  List<Object> get props => [id, name];

  @override
  String toString() => 'Faculty($id, $name)';
}

class Department extends Equatable {
  final int id;
  final String name;

  const Department({required this.id, required this.name});

  // Add factory constructor from DepartmentModel
  factory Department.fromModel(DepartmentModel model) {
    return Department(id: model.did, name: model.dname);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Department.fromJson(Map<String, dynamic> json) =>
      Department(id: json['id'] as int, name: json['name'] as String);

  @override
  List<Object> get props => [id, name];

  @override
  String toString() => 'Department($id, $name)';
}

abstract class FilterState extends Equatable {
  const FilterState();
}

class FilterInitial extends FilterState {
  @override
  List<Object> get props => [];
}

class FilterLoading extends FilterState {
  @override
  List<Object> get props => [];
}

class FilterLoaded extends FilterState {
  final Faculty? faculty;
  final Department? department;
  final String workArea;

  const FilterLoaded({this.faculty, this.department, this.workArea = ''});

  // CORRECTED copyWith method - null means "clear the value"
  FilterLoaded copyWith({
    Faculty? faculty,
    Department? department,
    String? workArea,
  }) {
    return FilterLoaded(
      faculty: faculty, // Pass null to clear
      department: department, // Pass null to clear
      workArea: workArea ?? this.workArea,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faculty': faculty?.toJson(),
      'department': department?.toJson(),
      'workArea': workArea,
    };
  }

  factory FilterLoaded.fromJson(Map<String, dynamic> json) {
    return FilterLoaded(
      faculty:
          json['faculty'] != null
              ? Faculty.fromJson(json['faculty'] as Map<String, dynamic>)
              : null,
      department:
          json['department'] != null
              ? Department.fromJson(json['department'] as Map<String, dynamic>)
              : null,
      workArea: json['workArea'] as String? ?? '',
    );
  }

  bool get hasActiveFilters {
    return faculty != null || department != null || workArea.isNotEmpty;
  }

  @override
  List<Object?> get props => [faculty, department, workArea];

  @override
  String toString() => 'FilterLoaded($faculty, $department, $workArea)';
}

class FilterError extends FilterState {
  final String message;

  const FilterError({required this.message});

  @override
  List<Object> get props => [message];
}

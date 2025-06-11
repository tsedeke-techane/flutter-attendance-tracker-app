class Course {
  final String id;
  final String name;
  final String section;
  final String? teacherId;   // Comes from "teacher" field
  final String? teacherName; // Comes from teacher's name (for students)
  final List<String> students; // List of student IDs
  final int studentCount;
  final String? attendance;
  // Derived from students.length

  Course({
    required this.id,
    required this.name,
    required this.section,
    this.teacherId,
    this.teacherName,
    this.attendance,
    
    List<String>? students,
    int? studentCount,
  }) : 
    this.students = students ?? const [],
    this.studentCount = studentCount ?? (students?.length ?? 0);

  factory Course.fromJson(Map<String, dynamic> json) {
    // Parse students field - handle different types safely
    List<String> parseStudents() {
      final studentsData = json['students'];
      if (studentsData == null) return [];
      
      if (studentsData is List) {
        return studentsData.map((student) {
          // Handle different types of student data
          if (student is String) {
            return student;
          } else if (student is Map<String, dynamic>) {
            return student['_id']?.toString() ?? '';
          } else {
            return student.toString();
          }
        }).where((id) => id.isNotEmpty).toList();
      }
      return [];
    }

    // Parse teacher info - handle different types safely
    String? teacherId;
    String? teacherName;
    
    final teacherData = json['teacher'];
    if (teacherData is String) {
      teacherId = teacherData;
    } else if (teacherData is Map<String, dynamic>) {
      teacherId = teacherData['_id']?.toString();
      teacherName = teacherData['name']?.toString();
    }

    // Handle section field - ensure it's a string
    String section = '';
    final sectionData = json['section'];
    if (sectionData != null) {
      section = sectionData.toString();
    }
    String attendance = '';
    if (json['attendance'] != null) {
      attendance = json['attendance'].toString();
    }

    // Calculate student count safely
    int studentCount = 0;
    final students = parseStudents();
    studentCount = students.length;
    
    // If there's a studentCount field in the JSON, use that instead
    if (json['studentCount'] != null) {
      try {
        studentCount = int.parse(json['studentCount'].toString());
      } catch (e) {
        // If parsing fails, use the length of students list
        studentCount = students.length;
      }
    }

    return Course(
      id: json['_id']?.toString() ?? '',
      name: json['className']?.toString() ?? '',
      section: section,
      teacherId: teacherId,
      teacherName: teacherName,
      students: students,
      studentCount: studentCount,
      attendance: attendance
    );
  }

  // Convert Course object to JSON
  Map<String, dynamic> toJson() {
    return {
      'className': name,
      'section': section,
      'teacher': teacherId,
      'students': students,
    };
  }
}

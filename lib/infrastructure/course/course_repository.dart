import 'package:crossplatform_flutter/domain/auth/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crossplatform_flutter/domain/course/course.dart';

class CourseRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  CourseRepository(this._dio, this._secureStorage);

  // Get all courses (generic method)
  Future<bool> addStudentToCourse(String courseId, String studentId, String studentName) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Not authenticated');
      final response = await _dio.post(
        '/teacher/class/$courseId/students',
        data: {'ID': studentId, 'name': studentName},
        options: Options(headers: {'Authorization Bearer': token}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to add student to course: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to add student to course: ${e.response?.data['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Error in addStudentToCourse: $e');
      throw Exception('Failed to add student to course: $e');
    }
  }
  Future<List<Course>> getAllCourses() async {
    try {
      print("what the fuck");
      final token = await _secureStorage.read(key: 'auth_token');
      print(token);
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '/class/student-dashboard',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print("my response");
      print(response);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is List) {
          return (data['data'] as List).map((courseJson) {
            if (courseJson is Map<String, dynamic>) {
              return Course.fromJson(courseJson);
            }
            // Skip invalid course data
            return null;
          }).whereType<Course>().toList();
        }
        return [];
      } else {
        throw Exception('Failed to load courses: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error in getAllCourses: $e');
      throw Exception('Failed to load courses: $e');
    }
  }
Future<List<User>> getStudentByCourseId(String courseId) async {
  try {
    print('Fetching students for course ID: $courseId');
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) throw Exception('Not authenticated');
    
    final response = await _dio.get(
      '/attendance/class/$courseId/history',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    print("Response data: ${response.data}");
    
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      
      // Access students from overallStats as shown in the response
      if (data['overallStats'] != null && data['overallStats']['students'] is List) {
        return (data['overallStats']['students'] as List)
          .map((studentJson) => User.fromJson(studentJson))
          .toList();
      } else {
        throw Exception('Invalid response format: expected array of students in overallStats');
      }
    } else {
      throw Exception('Failed to load students: ${response.statusMessage}');
    }
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception('Failed to load students: ${e.response?.data['message']}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  } catch (e) {
    print('Error in getStudentByCourseId: $e');
    rethrow;
  }
}

  // Get courses for a student
  Future<List<Course>> getStudentCourses(String studentId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '/student/courses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((courseJson) {
            if (courseJson is Map<String, dynamic>) {
              return User.fromJson(courseJson);
            }
            return null;
          }).whereType<Course>().toList();
        }
        return [];
      } else {
        throw Exception('Failed to load student courses: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load student courses: ${e.response?.data['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Error in getStudentCourses: $e');
      // For development/testing, return mock data
      return [
        Course(
          id: '1', 
          name: 'Cyber Security', 
          section: 'S1',
          teacherId: 'T123',
          teacherName: 'Dr. Smith',
          students: ['S1', 'S2', 'S3'],
        ),
        Course(
          id: '2', 
          name: 'Operating System', 
          section: 'S2',
          teacherId: 'T124',
          teacherName: 'Dr. Johnson',
          students: ['S1', 'S4', 'S5'],
        ),
        Course(
          id: '3', 
          name: 'Mobile', 
          section: 'S3',
          teacherId: 'T125',
          teacherName: 'Dr. Williams',
          students: ['S1', 'S6', 'S7'],
        ),
        Course(
          id: '4', 
          name: 'Artificial Intelligence', 
          section: 'S4',
          teacherId: 'T126',
          teacherName: 'Dr. Brown',
          students: ['S1', 'S8', 'S9'],
        ),
        Course(
          id: '5', 
          name: 'Graphics', 
          section: 'S5',
          teacherId: 'T127',
          teacherName: 'Dr. Davis',
          students: ['S1', 'S10', 'S11'],
        ),
        Course(
          id: '6', 
          name: 'Operating System', 
          section: 'S6',
          teacherId: 'T128',
          teacherName: 'Dr. Miller',
          students: ['S1', 'S12', 'S13'],
        ),
      ];
    }
  }

  // Get courses for a teacher
  Future<List<Course>> getTeacherCourses(String teacherId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '/teacher/courses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((courseJson) {
            if (courseJson is Map<String, dynamic>) {
              return Course.fromJson(courseJson);
            }
            return null;
          }).whereType<Course>().toList();
        }
        return [];
      } else {
        throw Exception('Failed to load teacher courses: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load teacher courses: ${e.response?.data['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Error in getTeacherCourses: $e');
      // For development/testing, return mock data based on the JSON structure provided
      return [
        Course(
          id: '681ca0baae40cfecd86a64c0',
          name: 'Physics',
          section: '4',
          teacherId: '681c9c43ae40cfecd86a6497',
          students: ['681b4b1f897edc2728cbdb77', '68175818d35292e4cf434576', '681f65be5a0035c832e2cc17'],
        ),
        Course(
          id: '681cbd918266adf4efec9a27',
          name: 'OS',
          section: '4',
          teacherId: '681c9c43ae40cfecd86a6497',
          students: ['681f65be5a0035c832e2cc17', '681b4b1f897edc2728cbdb77'],
        ),
        Course(
          id: '681cc2ea8266adf4efec9a5a',
          name: 'OS',
          section: '4',
          teacherId: '681c9c43ae40cfecd86a6497',
          students: ['681b4b1f897edc2728cbdb77'],
        ),
        Course(
          id: '681cc83d2a68e56e13740662',
          name: 'Web',
          section: 'S1',
          teacherId: '681c9c43ae40cfecd86a6497',
          students: ['681b4b1f897edc2728cbdb77'],
        ),
        Course(
          id: '681ccb012a68e56e13740676',
          name: 'Home',
          section: 'S1',
          teacherId: '681c9c43ae40cfecd86a6497',
          students: [],
        ),
        Course(
          id: '681cd6b62a68e56e1374069d',
          name: 'Bura',
          section: 'S1',
          teacherId: '681c9c43ae40cfecd86a6497',
          students: [],
        ),
      ];
    }
  }

  // Get a specific course by ID
  Future<Course> getCourseById(String courseId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '/courses/$courseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Course.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to load course: Invalid response format');
        }
      } else {
        throw Exception('Failed to load course: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load course: ${e.response?.data['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Error in getCourseById: $e');
      // For development/testing, return mock data
      return Course(
        id: courseId,
        name: 'Mock Course',
        section: 'S1',
        teacherId: 'T123',
        students: ['S1', 'S2', 'S3'],
      );
    }
  }
  Future<Course> createCourse(String name, String section, String schedule) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.post(
        '/teacher/create-class',
        data: {
          'className': name,
          'section': section,
          'schedule': schedule,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Course.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to create course: Invalid response format');
        }
      } else {
        throw Exception('Failed to create course: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create course: ${e.response?.data['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Error in createCourse: $e');
      throw Exception('Failed to create course: $e');
    }
  }

  // Other methods remain the same...
}

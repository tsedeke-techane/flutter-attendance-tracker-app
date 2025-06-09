import 'package:crossplatform_flutter/domain/auth/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/domain/course/course.dart';
import 'package:crossplatform_flutter/infrastructure/course/course_repository.dart';
import 'package:crossplatform_flutter/application/auth/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseController extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseRepository _courseRepository;
  final String? userId;
  final bool isTeacher; // We'll keep this for UI differentiation, but not for API calls

  CourseController(this._courseRepository, this.userId, this.isTeacher) 
      : super(const AsyncValue.loading()) {
    if (userId != null) {
      fetchCourses();
    }
  }

  Future<void> fetchCourses() async {
    state = const AsyncValue.loading();
    try {
      if (userId == null) {
        throw Exception('User ID is null');
      }
      
      // Use getAllCourses for both teachers and students
      final courses = await _courseRepository.getAllCourses();
      
      state = AsyncValue.data(courses);
    } catch (e) {
      print('Error in fetchCourses: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Course?> getCourseById(String courseId) async {
    try {
      return await _courseRepository.getCourseById(courseId);
    } catch (e) {
      print('Error in getCourseById: $e');
      return null;
    }
  }
  Future<List<User>> getStudentsByCourseId(String courseId) async {
    try {
      return await _courseRepository.getStudentByCourseId(courseId);
    } catch (e) {
      print('Error in getStudentsByCourseId: $e');
      return [];
    }
  }

  Future<Course?> createCourse(String name, String section, String schedule) async {
    try {
      if (userId == null) {
        throw Exception('User ID is null');
      }
      
   
      
      final createdCourse = await _courseRepository.createCourse(name, section, schedule);
      
      // Update the state with the new course
      final currentCourses = state.value ?? [];
      state = AsyncValue.data([...currentCourses, createdCourse]);
      
      return createdCourse;
    } catch (e) {
      print('Error in createCourse: $e');
      return null;
    }
  }


  Future<bool> addStudentToCourse(String courseId, String studentId, String studentName) async {
    try {
      await _courseRepository.addStudentToCourse(courseId, studentId, studentName);
      
      // Refresh courses to get updated data
      await fetchCourses();
      return true;
    } catch (e) {
      print('Error in addStudentToCourse: $e');
      return false;
    }
  }

  // Future<bool> removeStudentFromCourse(String courseId, String studentId) async {
  //   try {
  //     await _courseRepository.removeStudentFromCourse(courseId, studentId);
      
  //     // Refresh courses to get updated data
  //     await fetchCourses();
  //     return true;
  //   } catch (e) {
  //     print('Error in removeStudentFromCourse: $e');
  //     return false;
  //   }
  // }
  
  // Helper method to get a course by ID from the current state
  Course? findCourseById(String courseId) {
    final courses = state.value;
    if (courses == null) return null;
    
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }
}

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.5.90.151:5000', // Replace with your API URL
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  final secureStorage = const FlutterSecureStorage();
  return CourseRepository(dio, secureStorage);
});

// We'll keep separate providers for teacher and student views
// even though they use the same API endpoint
final studentCoursesProvider = StateNotifierProvider<CourseController, AsyncValue<List<Course>>>((ref) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  
  final userId = authState.value?.id;
  return CourseController(courseRepository, userId, false);
});

final teacherCoursesProvider = StateNotifierProvider<CourseController, AsyncValue<List<Course>>>((ref) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  
  final userId = authState.value?.id;
  return CourseController(courseRepository, userId, true);
});
final courseStudentsProvider = FutureProvider.family<List<User>, String>((ref, courseId) async {
  final courseController = ref.read(teacherCoursesProvider.notifier);
  return courseController.getStudentsByCourseId(courseId);
});
final courseByIdProvider = Provider.family<AsyncValue<Course?>, String>((ref, id) {
  final coursesState = ref.watch(studentCoursesProvider);
  
  // Try to find the course in the courses list
  return coursesState.when(
    data: (courses) {
      try {
        final course = courses.where((c) => c.id == id).firstOrNull;
        return AsyncValue.data(course);
      } catch (e) {
        print('Error finding course: $e');
        return const AsyncValue.data(null);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Provider to get a specific course directly from the repository
final courseDetailProvider = FutureProvider.family<Course?, String>((ref, courseId) async {
  try {
    final courseRepository = ref.watch(courseRepositoryProvider);
    return await courseRepository.getCourseById(courseId);
  } catch (e) {
    print('Error in courseDetailProvider: $e');
    return null;
  }
});

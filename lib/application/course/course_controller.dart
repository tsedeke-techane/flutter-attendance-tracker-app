import 'package:crossplatform_flutter/domain/auth/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/domain/course/course.dart';
import 'package:crossplatform_flutter/infrastructure/course/course_repository.dart';

class CourseController extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseRepository _courseRepository;
  final String? userId;
  final bool isTeacher; // For UI only

  CourseController(this._courseRepository, this.userId, this.isTeacher) 
      : super(const AsyncValue.loading()) {
    if (userId != null) {
      fetchCourses();
    }
  }

  Future<void> fetchCourses() async {
    state = const AsyncValue.loading();
    try {
      if (userId == null) throw Exception('User ID is null');
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
      if (userId == null) throw Exception('User ID is null');
      final createdCourse = await _courseRepository.createCourse(name, section, schedule);
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
      await fetchCourses();
      return true;
    } catch (e) {
      print('Error in addStudentToCourse: $e');
      return false;
    }
  }

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

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/application/course/course_controller.dart';
import 'package:crossplatform_flutter/infrastructure/course/course_repository.dart';
import 'package:crossplatform_flutter/domain/course/course.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

// Mock implementation of the CourseRepository
class MockCourseRepository extends Mock implements CourseRepository {}

// Mock Role Enum (Remove this if the Role enum is defined elsewhere in your project and import it instead)
enum Role {
  student,
  teacher,
}

void main() {
 
  late MockCourseRepository mockCourseRepository;
  late ProviderContainer container;
  late CourseController courseController;

  setUp(() {
    mockCourseRepository = MockCourseRepository();
    container = ProviderContainer(
      overrides: [
        courseRepositoryProvider.overrideWithValue(mockCourseRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CourseController - Student', () {
    setUp(() {
      courseController = CourseController(mockCourseRepository, '123', false);
    });

    final testCourses = [
      Course(
        id: '1',
        name: 'Math',
        section: 'A',
        teacherId: 'teacher1',
        teacherName: 'John Doe',
      ),
      Course(
        id: '2',
        name: 'Science',
        section: 'B',
        teacherId: 'teacher2',
        teacherName: 'Jane Smith',
      ),
    ];

    test('initial state should be AsyncLoading', () {
      expect(courseController.state, isA<AsyncLoading<List<Course>>>());
    });

    test('fetchCourses should update state to AsyncData with courses for student', () async {
      // Arrange
      when(() => mockCourseRepository.getAllCourses())
          .thenAnswer((_) async => testCourses);

      // Act
      await courseController.fetchCourses();

      // Assert
      expect(courseController.state, isA<AsyncData<List<Course>>>());
      expect(courseController.state.value, equals(testCourses));
      verify(() => mockCourseRepository.getAllCourses()).called(1);
    });

    test('fetchCourses should update state to AsyncError on failure', () async {
      // Arrange
      final exception = Exception('Failed to fetch courses');
      when(() => mockCourseRepository.getAllCourses())
          .thenThrow(exception);

      // Act
      await courseController.fetchCourses();

      // Assert
      expect(courseController.state, isA<AsyncError>());
      expect(courseController.state.error, equals(exception));
      verify(() => mockCourseRepository.getAllCourses()).called(1);
    });

    test('getCourseById should return the correct course', () async {
      // Arrange
      when(() => mockCourseRepository.getAllCourses())
          .thenAnswer((_) async => testCourses);
      await courseController.fetchCourses();

      // Act
      final result = courseController.findCourseById('1');

      // Assert
      expect(result, equals(testCourses[0]));
    });

    test('getCourseById should return null for non-existent course', () async {
      // Arrange
      when(() => mockCourseRepository.getAllCourses())
          .thenAnswer((_) async => testCourses);
      await courseController.fetchCourses();

      // Act
      final result = courseController.findCourseById('999');

      // Assert
      expect(result, isNull);
    });
  });

  group('CourseController - Teacher', () {
    setUp(() {
      courseController = CourseController(mockCourseRepository, '456', true);
    });

    final testCourses = [
      Course(
        id: '3',
        name: 'History',
        section: 'C',
        teacherId: '456',
        studentCount: 25,
      ),
      Course(
        id: '4',
        name: 'English',
        section: 'D',
        teacherId: '456',
        studentCount: 30,
      ),
    ];

    final testStudents = [
      User(
        id: 'student1',
        name: 'Student One',
        email: 'student1@example.com',
        ID: 'S001',
        role: UserRole.student,
      ),
      User(
        id: 'student2',
        name: 'Student Two',
        email: 'student2@example.com',
        ID: 'S002',
        role: UserRole.student,
      ),
    ];

    test('fetchCourses should update state to AsyncData with courses for teacher', () async {
      // Arrange
      when(() => mockCourseRepository.getAllCourses())
          .thenAnswer((_) async => testCourses);

      // Act
      await courseController.fetchCourses();

      // Assert
      expect(courseController.state, isA<AsyncData<List<Course>>>());
      expect(courseController.state.value, equals(testCourses));
      verify(() => mockCourseRepository.getAllCourses()).called(1);
    });

    test('getStudentsByCourseId should return students for a course', () async {
      // Arrange
      when(() => mockCourseRepository.getStudentByCourseId('3'))
          .thenAnswer((_) async => testStudents);

      // Act
      final result = await courseController.getStudentsByCourseId('3');

      // Assert
      expect(result, equals(testStudents));
      verify(() => mockCourseRepository.getStudentByCourseId('3')).called(1);
    });

    test('getStudentsByCourseId should throw exception on failure', () async {
      // Arrange
      final exception = Exception('Failed to fetch students');
      when(() => mockCourseRepository.getStudentByCourseId('3'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => courseController.getStudentsByCourseId('3'),
        throwsA(equals(exception)),
      );
    });
  });
}

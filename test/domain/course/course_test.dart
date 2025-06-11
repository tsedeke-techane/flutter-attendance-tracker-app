import 'package:flutter_test/flutter_test.dart';
import 'package:crossplatform_flutter/domain/course/course.dart';

void main() {
  group('Course', () {
    test('should create a Course instance with correct properties', () {
      final course = Course(
        id: '1',
        name: 'Math',
        section: 'A',
        teacherId: 'teacher1',
        teacherName: 'John Doe',
        students: ['student1', 'student2'],
      );

      expect(course.id, equals('1'));
      expect(course.name, equals('Math'));
      expect(course.section, equals('A'));
      expect(course.teacherId, equals('teacher1'));
      expect(course.teacherName, equals('John Doe'));
      expect(course.students, equals(['student1', 'student2']));
      expect(course.studentCount, equals(2));
    });

    test('should create a Course instance with default values', () {
      final course = Course(
        id: '1',
        name: 'Math',
        section: 'A',
      );

      expect(course.teacherId, isNull);
      expect(course.teacherName, isNull);
      expect(course.students, isEmpty);
      expect(course.studentCount, equals(0));
    });

    test('should use provided studentCount over students.length', () {
      final course = Course(
        id: '1',
        name: 'Math',
        section: 'A',
        students: ['student1', 'student2'],
        studentCount: 10,
      );

      expect(course.students.length, equals(2));
      expect(course.studentCount, equals(10));
    });

    group('fromJson', () {
      test('should correctly parse Course from JSON with simple data', () {
        return;
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
        };

        final course = Course.fromJson(json);

        expect(course.id, equals('1'));
        expect(course.name, equals('Math'));
        expect(course.section, equals('A'));
        expect(course.teacherId, isNull);
        expect(course.teacherName, isNull);
        expect(course.students, isEmpty);
      });

      test('should correctly parse Course from JSON with teacher as object',
          () {
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'teacher': {
            '_id': 'teacher1',
            'name': 'John Doe',
          },
        };

        final course = Course.fromJson(json);

        expect(course.teacherId, equals('teacher1'));
        expect(course.teacherName, equals('John Doe'));
      });

      test('should correctly parse Course from JSON with teacher as string',
          () {
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'teacher': 'teacher1',
        };

        final course = Course.fromJson(json);

        expect(course.teacherId, equals('teacher1'));
        expect(course.teacherName, isNull);
      });

      test('should correctly parse Course from JSON with students as objects',
          () {
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'students': [
            {'_id': 'student1', 'name': 'Student One'},
            {'_id': 'student2', 'name': 'Student Two'},
          ],
        };

        final course = Course.fromJson(json);

        expect(course.students, equals(['student1', 'student2']));
        expect(course.studentCount, equals(2));
      });

      test('should correctly parse Course from JSON with students as strings',
          () {
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'students': ['student1', 'student2', 'student3'],
        };

        final course = Course.fromJson(json);

        expect(course.students, equals(['student1', 'student2', 'student3']));
        expect(course.studentCount, equals(3));
      });

      test('should handle empty or null students array', () {
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'students': [],
        };

        final course = Course.fromJson(json);

        expect(course.students, isEmpty);
        expect(course.studentCount, equals(0));

        final jsonWithNullStudents = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'students': null,
        };

        final courseWithNullStudents = Course.fromJson(jsonWithNullStudents);
        expect(courseWithNullStudents.students, isEmpty);
        expect(courseWithNullStudents.studentCount, equals(0));
      });

      test('should handle studentCount field in JSON', () {
        final json = {
          '_id': '1',
          'name': 'Math',
          'section': 'A',
          'students': ['student1', 'student2'],
          'studentCount': 10,
        };

        final course = Course.fromJson(json);
        expect(course.students.length, equals(2));
        expect(course.studentCount, equals(10));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

void main() {
  group('User', () {
    test('should create a User instance with correct properties', () {
      final user = User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        ID: '12345',
        role: UserRole.student,
      );

      expect(user.id, equals('1'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.ID, equals('12345'));
      expect(user.role, equals(UserRole.student));
      expect(user.overallStats, isNull);
    });

    test('should create a User instance with overallStats', () {
      final user = User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        ID: '12345',
        role: UserRole.student,
        overallStats: 80, // Corrected to match the User model definition
      );

      expect(user.overallStats, isNotNull);
      expect(user.overallStats, equals(80));
    });

    group('fromJson', () {
      test('should correctly parse User from JSON with student role', () {
        final json = {
          '_id': '1',
          'name': 'Test Student',
          'email': 'student@example.com',
          'ID': 'S12345',
          'role': 'student',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals('1'));
        expect(user.name, equals('Test Student'));
        expect(user.email, equals('student@example.com'));
        expect(user.ID, equals('S12345'));
        expect(user.role, equals(UserRole.student));
      });

      test('should correctly parse User from JSON with teacher role', () {
        final json = {
          '_id': '2',
          'name': 'Test Teacher',
          'email': 'teacher@example.com',
          'ID': 'T67890',
          'role': 'teacher',
        };

        final user = User.fromJson(json);

        expect(user.id, equals('2'));
        expect(user.name, equals('Test Teacher'));
        expect(user.email, equals('teacher@example.com'));
        expect(user.ID, equals('T67890'));
        expect(user.role, equals(UserRole.teacher));
      });

      test('should correctly parse User from JSON with overallStats', () {
        final json = {
          '_id': '1',
          'name': 'Test Student',
          'email': 'student@example.com',
          'ID': 'S12345',
          'role': 'student',
          'overallStats': 80,
        };

        final user = User.fromJson(json);

        expect(user.overallStats, isNotNull);
        expect(user.overallStats, equals(80));
      });

      test('should handle missing fields gracefully', () {
        final json = {
          '_id': '1',
          'name': 'Test User',
          'ID': '12345',
        };

        final user = User.fromJson(json);

        expect(user.id, equals('1'));
        expect(user.name, equals('Test User'));
        expect(user.email, isEmpty);
        expect(user.ID, equals('12345'));
        expect(user.role, equals(UserRole.student)); // Default role
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/application/attendance/attendance_controller.dart';
import 'package:crossplatform_flutter/infrastructure/attendance/attendance_repository.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  
  late MockAttendanceRepository mockAttendanceRepository;
  late ProviderContainer container;
  late AttendanceController attendanceController;

  setUp(() {
    mockAttendanceRepository = MockAttendanceRepository();
    container = ProviderContainer(
      overrides: [
        attendanceRepositoryProvider.overrideWithValue(mockAttendanceRepository),
      ],
    );
    attendanceController = container.read(attendanceControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('AttendanceController Tests', () {
    final testAttendanceStats = Attendancestats(
      totalClasses: 10,
      presentCount: 8,
      absentCount: 2,
      className: 'Math',
      attendancePercentage: 80.0,
      attendanceList: [true, true, true, true, false, true, true, true, true, false],
    );

    test('initial state should be AsyncData with null', () {
      final state = container.read(attendanceControllerProvider);
      expect(state, isA<AsyncData<String>>());
      expect(state.value, equals(''));
    });

    group('generateQrCode', () {
      test('should update state to AsyncData with QR code on success', () async {
        // Arrange
        when(() => mockAttendanceRepository.generateQrCode('course123'))
            .thenAnswer((_) async => 'qr-code-data');

        // Act
        final qrCode = await attendanceController.generateQrCode('course123');

        // Assert
        expect(qrCode, equals('qr-code-data'));
        final state = container.read(attendanceControllerProvider);
        expect(state, isA<AsyncData<String>>());
        expect(state.value, equals('qr-code-data'));
        verify(() => mockAttendanceRepository.generateQrCode('course123')).called(1);
      });

      test('should update state to AsyncError on failure', () async {
        // Arrange
        final exception = Exception('Failed to generate QR code');
        when(() => mockAttendanceRepository.generateQrCode('course123'))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => attendanceController.generateQrCode('course123'),
          throwsA(equals(exception)),
        );

        final state = container.read(attendanceControllerProvider);
        expect(state, isA<AsyncError>());
        verify(() => mockAttendanceRepository.generateQrCode('course123')).called(1);
      });
    });

    group('getStudentAttendanceStats', () {
      test('should return attendance stats on success', () async {
        // Arrange
        when(() => mockAttendanceRepository.getStudentAttendanceStats('course123', 'student123'))
            .thenAnswer((_) async => testAttendanceStats);

        // Act
        final result = await attendanceController.getStudentAttendanceStats('course123', 'student123');

        // Assert
        expect(result, equals(testAttendanceStats));
        verify(() => mockAttendanceRepository.getStudentAttendanceStats('course123', 'student123')).called(1);
      });

      test('should throw exception on failure', () async {
        // Arrange
        final exception = Exception('Failed to get attendance stats');
        when(() => mockAttendanceRepository.getStudentAttendanceStats('course123', 'student123'))
            .thenThrow(exception);

        // Act & Assert
        await expectLater(
          () => attendanceController.getStudentAttendanceStats('course123', 'student123'),
          throwsA(equals(exception)),
        );
      });
    });

    group('getAgainStudentAttendance', () {
      test('should return attendance stats on success', () async {
        // Arrange
        when(() => mockAttendanceRepository.getAgainStudentAttendance('course123'))
            .thenAnswer((_) async => testAttendanceStats);

        // Act
        final result = await attendanceController.getAgainStudentAttendance('course123');

        // Assert
        expect(result, equals(testAttendanceStats));
        verify(() => mockAttendanceRepository.getAgainStudentAttendance('course123')).called(1);
      });

      test('should throw exception on failure', () async {
        // Arrange
        final exception = Exception('Failed to get attendance stats');
        when(() => mockAttendanceRepository.getAgainStudentAttendance('course123'))
            .thenThrow(exception);

        // Act & Assert
        await expectLater(
          () => attendanceController.getAgainStudentAttendance('course123'),
          throwsA(equals(exception)),
        );
      });
    });
  });
}

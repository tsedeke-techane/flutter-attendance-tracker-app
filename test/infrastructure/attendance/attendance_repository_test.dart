import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crossplatform_flutter/infrastructure/attendance/attendance_repository.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';
import 'package:crossplatform_flutter/core/errors/AttendanceError.dart';

class MockDio extends Mock implements Dio {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDio mockDio;
  late MockFlutterSecureStorage mockSecureStorage;
  late AttendanceRepository attendanceRepository;

  setUp(() {
    mockDio = MockDio();
    mockSecureStorage = MockFlutterSecureStorage();
    attendanceRepository = AttendanceRepository(mockDio, mockSecureStorage);

    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  group('AttendanceRepository', () {
    const testToken = 'test-token';

    setUp(() {
      when(() => mockSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => testToken);
    });

    group('getStudentAttendanceStats', () {
      test('should return attendance stats on successful fetch', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn({
          'statistics': {
            'totalClasses': 10,
            'presentCount': 8,
            'absentCount': 2,
            'attendancePercentage': 80.0,
          },
          'history': [
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'absent'},
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'absent'},
          ],
          'class': {
            'name': 'Math',
          }
        });

        when(() => mockDio.post(
              '/class/course123/history',
              data: {'studentId': 'student123'},
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await attendanceRepository.getStudentAttendanceStats('course123', 'student123');

        expect(result, isA<Attendancestats>());
        expect(result!.totalClasses, equals(10));
        expect(result.presentCount, equals(8));
        expect(result.absentCount, equals(2));
        expect(result.attendancePercentage, equals(80.0));
        expect(result.className, equals('Math'));
        expect(result.attendanceList.length, equals(10));
        expect(result.attendanceList[0], isTrue);
        expect(result.attendanceList[4], isFalse);

        verify(() => mockDio.post(
              '/class/course123/history',
              data: {'studentId': 'student123'},
              options: any(named: 'options'),
            )).called(1);
      });

      test('should throw AttendanceException on fetch failure', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/class/course123/history'),
          response: Response(
            statusCode: 404,
            data: {'message': 'Course not found'},
            requestOptions: RequestOptions(path: '/class/course123/history'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.post(
              '/class/course123/history',
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(dioException);

        expect(
          () => attendanceRepository.getStudentAttendanceStats('course123', 'student123'),
          throwsA(isA<AttendanceException>()),
        );
      });
    });

    group('generateQrCode', () {
      test('should return QR code data on successful generation', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn({
          'qrCodeImage': 'qr-code-data-123',
        });

        when(() => mockDio.post(
              '/generate',
              data: {'classId': 'course123'},
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await attendanceRepository.generateQrCode('course123');

        expect(result, equals('qr-code-data-123'));

        verify(() => mockDio.post(
              '/generate',
              data: {'classId': 'course123'},
              options: any(named: 'options'),
            )).called(1);
      });

      test('should throw QrGenerationException on generation failure', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/generate'),
          response: Response(
            statusCode: 500,
            data: {'message': 'Server error'},
            requestOptions: RequestOptions(path: '/generate'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.post(
              '/generate',
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(dioException);

        expect(
          () => attendanceRepository.generateQrCode('course123'),
          throwsA(isA<QrGenerationException>()),
        );
      });
    });

    group('scanQrCode', () {
      test('should return true on successful scan', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn({'success': true});

        when(() => mockDio.post(
              '/scan',
              data: {'token': 'some-token', 'classId': 'class123'},
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await attendanceRepository.scanQrCode('some-token', 'class123');

        expect(result, isTrue);

        verify(() => mockDio.post(
              '/scan',
              data: {'token': 'some-token', 'classId': 'class123'},
              options: any(named: 'options'),
            )).called(1);
      });

      test('should throw QrScanningException on failure', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/scan'),
          response: Response(
            statusCode: 400,
            data: {'message': 'Invalid token'},
            requestOptions: RequestOptions(path: '/scan'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.post(
              '/scan',
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(dioException);

        expect(
          () => attendanceRepository.scanQrCode('invalid-token', 'class123'),
          throwsA(isA<QrScanningException>()),
        );
      });
    });

    group('getAgainStudentAttendance', () {
      test('should return attendance stats on successful fetch', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn({
          'statistics': {
            'totalClasses': 5,
            'presentCount': 4,
            'absentCount': 1,
            'attendancePercentage': 80.0,
          },
          'history': [
            {'status': 'present'},
            {'status': 'absent'},
            {'status': 'present'},
            {'status': 'present'},
            {'status': 'present'},
          ],
          'class': {
            'name': 'Science',
          }
        });

        when(() => mockDio.get(
              '/history/class/course123',
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await attendanceRepository.getAgainStudentAttendance('course123');

        expect(result, isA<Attendancestats>());
        expect(result!.totalClasses, equals(5));
        expect(result.presentCount, equals(4));
        expect(result.absentCount, equals(1));
        expect(result.attendancePercentage, equals(80.0));
        expect(result.className, equals('Science'));
        expect(result.attendanceList.length, equals(5));
        expect(result.attendanceList[0], isTrue);
        expect(result.attendanceList[1], isFalse);

        verify(() => mockDio.get(
              '/history/class/course123',
              options: any(named: 'options'),
            )).called(1);
      });

      test('should throw AttendanceException on fetch failure', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/history/class/course123'),
          response: Response(
            statusCode: 404,
            data: {'message': 'Class not found'},
            requestOptions: RequestOptions(path: '/history/class/course123'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.get(
              '/history/class/course123',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        expect(
          () => attendanceRepository.getAgainStudentAttendance('course123'),
          throwsA(isA<AttendanceException>()),
        );
      });
    });
  });
}

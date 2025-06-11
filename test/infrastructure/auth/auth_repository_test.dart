import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crossplatform_flutter/infrastructure/auth/auth_repository.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

class MockDio extends Mock implements Dio {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDio mockDio;
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthRepository authRepository;

  setUp(() {
    mockDio = MockDio();
    mockSecureStorage = MockFlutterSecureStorage();
    authRepository = AuthRepository(mockDio, mockSecureStorage);
    registerFallbackValue(Uri());
  });

  group('AuthRepository', () {
    group('signIn', () {
      test('should return User on successful sign in', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn({
          'token': 'test-token',
          'user': {
            '_id': '1',
            'name': 'Test User',
            'email': 'test@example.com',
            'ID': '12345',
            'role': 'student',
          }
        });

        when(() => mockDio.post(
              '/auth/login',
              data: any(named: 'data'),
            )).thenAnswer((_) async => mockResponse);

        when(() => mockSecureStorage.write(
              key: 'auth_token',
              value: 'test-token',
            )).thenAnswer((_) async {});

        // Act
        final result = await authRepository.signIn('12345', 'password');

        // Assert
        expect(result, isA<User>());
        expect(result!.id, equals('1'));
        expect(result.name, equals('Test User'));
        expect(result.email, equals('test@example.com'));
        expect(result.ID, equals('12345'));
        expect(result.role, equals(UserRole.student));

        verify(() => mockDio.post(
              '/auth/login',
              data: {'ID': '12345', 'password': 'password'},
            )).called(1);

        verify(() => mockSecureStorage.write(
              key: 'auth_token',
              value: 'test-token',
            )).called(1);
      });

      test('should throw exception on sign in failure', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.post(
              '/auth/login',
              data: any(named: 'data'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => authRepository.signIn('12345', 'wrong-password'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signUp', () {
      test('should return User on successful sign up', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn({
          'token': 'test-token',
          'user': {
            '_id': '1',
            'name': 'New User',
            'email': 'new@example.com',
            'ID': '67890',
            'role': 'teacher',
          }
        });

        when(() => mockDio.post(
              '/auth/register',
              data: any(named: 'data'),
            )).thenAnswer((_) async => mockResponse);

        when(() => mockSecureStorage.write(
              key: 'auth_token',
              value: 'test-token',
            )).thenAnswer((_) async {});

        // Act
        final result = await authRepository.signUp(
          'New User',
          '67890',
          'new@example.com',
          'password',
          UserRole.teacher,
        );

        // Assert
        expect(result, isA<User>());
        expect(result.id, equals('1'));
        expect(result.name, equals('New User'));
        expect(result.email, equals('new@example.com'));
        expect(result.ID, equals('67890'));
        expect(result.role, equals(UserRole.teacher));

        verify(() => mockDio.post(
              '/auth/register',
              data: {
                'name': 'New User',
                'ID': '67890',
                'email': 'new@example.com',
                'password': 'password',
                'role': 'teacher',
              },
            )).called(1);

        verify(() => mockSecureStorage.write(
              key: 'auth_token',
              value: 'test-token',
            )).called(1);
      });

      test('should throw exception on sign up failure', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/register'),
          response: Response(
            statusCode: 400,
            data: {'message': 'Email already exists'},
            requestOptions: RequestOptions(path: '/auth/register'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.post(
              '/auth/register',
              data: any(named: 'data'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => authRepository.signUp(
            'New User',
            '67890',
            'existing@example.com',
            'password',
            UserRole.teacher,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signOut', () {
      test('should delete token on successful sign out', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        
        when(() => mockSecureStorage.read(key: 'auth_token'))
            .thenAnswer((_) async => 'test-token');
            
        when(() => mockDio.post(
              '/auth/logout',
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);
            
        when(() => mockSecureStorage.delete(key: 'auth_token'))
            .thenAnswer((_) async {});

        // Act
        await authRepository.signOut();

        // Assert
        verify(() => mockSecureStorage.read(key: 'auth_token')).called(1);
        verify(() => mockDio.post(
              '/auth/logout',
              options: any(named: 'options'),
            )).called(1);
        verify(() => mockSecureStorage.delete(key: 'auth_token')).called(1);
      });

      test('should delete token even if API call fails', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/logout'),
          type: DioExceptionType.connectionError,
        );
        
        when(() => mockSecureStorage.read(key: 'auth_token'))
            .thenAnswer((_) async => 'test-token');
            
        when(() => mockDio.post(
              '/auth/logout',
              options: any(named: 'options'),
            )).thenThrow(dioException);
            
        when(() => mockSecureStorage.delete(key: 'auth_token'))
            .thenAnswer((_) async {});

        // Act & Assert
        try {
          await authRepository.signOut();
          fail('Expected an exception to be thrown');
        } catch (e) {
          expect(e, isA<Exception>());
        }
        
        // Verify that methods were called regardless of exception
        verify(() => mockSecureStorage.read(key: 'auth_token')).called(1);
        verify(() => mockDio.post(
              '/auth/logout',
              options: any(named: 'options'),
            )).called(1);
        verify(() => mockSecureStorage.delete(key: 'auth_token')).called(1);
      });
    });

    group('checkAuth', () {
      test('should return User when token is valid', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn({
          'user': {
            '_id': '1',
            'name': 'Test User',
            'email': 'test@example.com',
            'ID': '12345',
            'role': 'student',
          }
        });
        
        when(() => mockSecureStorage.read(key: 'auth_token'))
            .thenAnswer((_) async => 'test-token');
            
        when(() => mockDio.get(
              '/auth/me',
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.checkAuth();

        // Assert
        expect(result, isA<User>());
        expect(result!.id, equals('1'));
        expect(result.name, equals('Test User'));
        expect(result.email, equals('test@example.com'));
        expect(result.ID, equals('12345'));
        expect(result.role, equals(UserRole.student));
        
        verify(() => mockSecureStorage.read(key: 'auth_token')).called(1);
        verify(() => mockDio.get(
              '/auth/me',
              options: any(named: 'options'),
            )).called(1);
      });

      test('should return null when no token exists', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'auth_token'))
            .thenAnswer((_) async => null);

        // Act
        final result = await authRepository.checkAuth();

        // Assert
        expect(result, isNull);
        verify(() => mockSecureStorage.read(key: 'auth_token')).called(1);
        verifyNever(() => mockDio.get(any()));
      });

      test('should return null when API call fails', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          type: DioExceptionType.badResponse,
        );
        
        when(() => mockSecureStorage.read(key: 'auth_token'))
            .thenAnswer((_) async => 'test-token');
            
        when(() => mockDio.get(
              '/auth/me',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        // Act
        final result = await authRepository.checkAuth();

        // Assert
        expect(result, isNull);
        verify(() => mockSecureStorage.read(key: 'auth_token')).called(1);
        verify(() => mockDio.get(
              '/auth/me',
              options: any(named: 'options'),
            )).called(1);
      });
    });
  });
}

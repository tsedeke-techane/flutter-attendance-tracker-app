import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/application/auth/auth_controller.dart';
import 'package:crossplatform_flutter/infrastructure/auth/auth_repository.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late AuthController authController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
    authController = container.read(authControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController', () {
    final testUser = User(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      ID: '12345',
      role: UserRole.student,
    );

    test('initial state should be AsyncData with null', () {
      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncData<User?>>());
      expect(state.value, isNull);
    });

    group('signIn', () {
      test('should update state to AsyncData with user on successful sign in', () async {
        // Arrange
        when(() => mockAuthRepository.signIn('12345', 'password'))
            .thenAnswer((_) async => testUser);

        // Act
        await authController.signIn('Test User', '12345', 'password');

        // Assert
        final state = container.read(authControllerProvider);
        expect(state, isA<AsyncData<User?>>());
        expect(state.value, equals(testUser));
        verify(() => mockAuthRepository.signIn('12345', 'password')).called(1);
      });

      test('should update state to AsyncError on sign in failure', () async {
        // Arrange
        final exception = Exception('Sign in failed');
        when(() => mockAuthRepository.signIn('12345', 'password'))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => authController.signIn('Test User', '12345', 'password'),
          throwsA(equals(exception)),
        );

        // Verify state
        final state = container.read(authControllerProvider);
        expect(state, isA<AsyncError>());
        expect(state.error, equals(exception));
        verify(() => mockAuthRepository.signIn('12345', 'password')).called(1);
      });
    });

    group('signUp', () {
      test('should update state to AsyncData with user on successful sign up', () async {
        // Arrange
        when(() => mockAuthRepository.signUp(
              'Test User',
              '12345',
              'test@example.com',
              'password',
              UserRole.student,
            )).thenAnswer((_) async => testUser);

        // Act
        await authController.signUp(
          'Test User',
          '12345',
          'test@example.com',
          'password',
          UserRole.student,
        );

        // Assert
        final state = container.read(authControllerProvider);
        expect(state, isA<AsyncData<User?>>());
        expect(state.value, equals(testUser));
        verify(() => mockAuthRepository.signUp(
              'Test User',
              '12345',
              'test@example.com',
              'password',
              UserRole.student,
            )).called(1);
      });

      test('should update state to AsyncError on sign up failure', () async {
        // Arrange
        final exception = Exception('Sign up failed');
        when(() => mockAuthRepository.signUp(
              'Test User',
              '12345',
              'test@example.com',
              'password',
              UserRole.student,
            )).thenThrow(exception);

        // Act & Assert
        expect(
          () => authController.signUp(
                'Test User',
                '12345',
                'test@example.com',
                'password',
                UserRole.student,
              ),
          throwsA(equals(exception)),
        );

        // Verify state
        final state = container.read(authControllerProvider);
        expect(state, isA<AsyncError>());
        expect(state.error, equals(exception));
        verify(() => mockAuthRepository.signUp(
              'Test User',
              '12345',
              'test@example.com',
              'password',
              UserRole.student,
            )).called(1);
      });
    });

    group('signOut', () {
      test('should update state to AsyncData with null on sign out', () async {
        // Arrange - first sign in to have a user in state
        when(() => mockAuthRepository.signIn('12345', 'password'))
            .thenAnswer((_) async => testUser);
        await authController.signIn('Test User', '12345', 'password');
        
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async {});

        // Act
        await authController.signOut();

        // Assert
        final state = container.read(authControllerProvider);
        expect(state, isA<AsyncData<User?>>());
        expect(state.value, isNull);
        verify(() => mockAuthRepository.signOut()).called(1);
      });

      test('should update state to AsyncError on sign out failure', () async {
        // Arrange - first sign in to have a user in state
        when(() => mockAuthRepository.signIn('12345', 'password'))
            .thenAnswer((_) async => testUser);
        await authController.signIn('Test User', '12345', 'password');
        
        final exception = Exception('Sign out failed');
        when(() => mockAuthRepository.signOut()).thenThrow(exception);

        // Act & Assert
        expect(
          () => authController.signOut(),
          throwsA(equals(exception)),
        );

        // Verify state
        final state = container.read(authControllerProvider);
        expect(state, isA<AsyncError>());
        expect(state.error, equals(exception));
        verify(() => mockAuthRepository.signOut()).called(1);
      });
    });
  });
}

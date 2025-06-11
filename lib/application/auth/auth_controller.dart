import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';
import 'package:crossplatform_flutter/infrastructure/auth/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// #  e <s ,f>
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signIn(String name, String id, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signIn(id, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e; // Re-throw to handle in UI
    }
  }

  Future<void> signUp(String name, String id, String email, String password, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUp(name, id, email, password, role);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e; // Re-throw to handle in UI
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e; // Re-throw to handle in UI
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://172.16.20.7:5000/api', // Replace with your API URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  final secureStorage = const FlutterSecureStorage();
  return AuthRepository(dio, secureStorage);
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.value != null;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.value?.role;
});

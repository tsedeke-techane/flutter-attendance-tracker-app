import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._dio, this._secureStorage);

Future<User?> signIn(String id, String password) async {
  try {
    final response = await _dio.post(
      '/auth/login',
      data: {'ID': id, 'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _secureStorage.write(
        key: 'auth_token',
        value: response.data['token'],
      );
      
      // Use User.fromJson
      return User.fromJson(response.data['user']);
    }
  } catch (e) {
    print('Sign-in error: $e');
    rethrow;
  }
  return null;
}

  Future<User> signUp(String name, String id, String email, String password, UserRole role) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'ID': id,
          'email': email,
          'password': password,
          'role': role == UserRole.teacher ? 'teacher' : 'student',
        },
      );

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token to secure storage
        final token = response.data['token'];
        await _secureStorage.write(key: 'auth_token', value: token);

         return User.fromJson(response.data['user']);
        
      } else {
        throw Exception('Failed to register: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // The server responded with an error
        final errorMessage = e.response?.data['message'] ?? 'Unknown error occurred';
        throw Exception('Registration failed: $errorMessage');
      } else {
        // Something happened in setting up the request
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      // Get token from secure storage
      final token = await _secureStorage.read(key: 'auth_token');
      
      if (token != null) {
        // Call logout API if needed
        await _dio.post(
          '/auth/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      
      // Clear token from secure storage
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      // Even if API call fails, still delete the token
      await _secureStorage.delete(key: 'auth_token');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Method to check if user is already logged in
  Future<User?> checkAuth() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      if (token == null) {
        return null;
      }
      
      // Verify token with backend
      final response = await _dio.get(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
         return User.fromJson(response.data['user']);
      }
      
      return null;
    } catch (e) {
      // If any error occurs, consider user not authenticated
      return null;
    }
  }
}

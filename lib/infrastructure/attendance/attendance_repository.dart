import 'package:crossplatform_flutter/core/errors/AttendanceError.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AttendanceRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AttendanceRepository(this._dio, this._secureStorage);
   Future<Attendancestats?> getStudentAttendanceStats(String courseId, String studentId) async {
    try {
      print("i am in attendance repository");
      print(courseId);
      print("and with");
      print(studentId);
      final token = await _secureStorage.read(key: 'auth_token');
      print("and my token is");
      print(token);
      final response = await _dio.post(
        '/class/$courseId/history',
        data: {'studentId': studentId},
        options: Options(headers: {
          'Authorization': 'Bearer $token'
        })
      );
      print("the response is");
      print(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The QR code check seems out of place here since your endpoint returns attendance stats
        // If you need both, you should handle them separately
        print("modified response");
        print(Attendancestats.fromJson(response.data));
        return  Attendancestats.fromJson(response.data);
      } else {
        throw AttendanceException(
          message: response.data['message'] ?? 'Failed to fetch attendance stats',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print("i have error bitch");
      print(e.message);
      throw AttendanceException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (error) {
      print("i have the second error bitch");
      print(error);
      throw AttendanceException(
        message: 'An unexpected error occurred',
        statusCode: 500,
      );
    }
  }
  Future<Attendancestats?> getAgainStudentAttendance(String courseId)async{
    try{
      final token = await _secureStorage.read(key: 'auth_token');
         final response = await _dio.get(
        '/history/class/$courseId',
       
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
       if (response.statusCode == 200 || response.statusCode == 201) {
        // The QR code check seems out of place here since your endpoint returns attendance stats
        // If you need both, you should handle them separately
        print("modified response");
        print(Attendancestats.fromJson(response.data));
        return  Attendancestats.fromJson(response.data);
      } else {
        throw AttendanceException(
          message: response.data['message'] ?? 'Failed to fetch attendance stats',
          statusCode: response.statusCode,
        );
      }

    }on DioException catch (e) {
      print("i have error bitch");
      print(e.message);
      throw AttendanceException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (error) {
      print("i have the second error bitch");
      print(error);
      throw AttendanceException(
        message: 'An unexpected error occurred',
        statusCode: 500,
      );
    }
  }


  Future<String> generateQrCode(String classId) async {
    print("I am in the generateQrCode method");
    print("Class ID: $classId");
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      print("my tojen is");
      print(token);
      
      final response = await _dio.post(
        '/generate',
      data: {
        'classId': classId
      },
       
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      print("the response is");
      print(response);
      print("Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final qrCode = response.data['qrCodeImage'] as String?;
        print("QR Code: $qrCode");
        print(qrCode);
        if (qrCode == null) {
          throw QrGenerationException(
            message: 'QR code data is malformed',
            statusCode: response.statusCode,
          );
        }
        return qrCode;
      } else {
        throw QrGenerationException(
          message: response.data['message'] ?? 'Failed to generate QR code',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw QrGenerationException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      throw QrGenerationException(
        message: 'Unexpected error occurred',
        error: e,
      );
    }
  }

  Future<bool> scanQrCode(String tokenn, String classId) async {
    try {
      print("i the repository am tryin with this bitch nigga");
      print("token  and classId of $classId");
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await _dio.post(
        '/scan',
        data: {
          'token': tokenn,
          'classId': classId,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        return response.data['success'] as bool? ?? false;
      } else {
        throw QrScanningException(
          message: response.data['message'] ?? 'Failed to scan QR code',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw QrScanningException(
        message: e.response?.data['message'] ?? 'Network error during scanning',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      throw QrScanningException(
        message: 'Unexpected scanning error',
        error: e,
      );
    }
  }
}

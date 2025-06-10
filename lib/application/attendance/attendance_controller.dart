
import 'package:crossplatform_flutter/core/errors/AttendanceError.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';
import 'package:crossplatform_flutter/infrastructure/attendance/attendance_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'http://10.5.90.151:5000/attendance',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
});

// SecureStorage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// AttendanceRepository Provider
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AttendanceRepository(dio, secureStorage);
});

// AttendanceController with proper state typing
class AttendanceController extends StateNotifier<AsyncValue<String>> {
  final AttendanceRepository _attendanceRepository;
  bool _isGenerating = false;
  String? _lastCourseId; // Track last generated course
  
  AttendanceController(this._attendanceRepository) : super(const AsyncValue.data(''));



Future<Attendancestats?> getAgainStudentAttendance(String courseId)async{
  try{
    final state=await _attendanceRepository.getAgainStudentAttendance(courseId);
    return state;

  }on AttendanceException catch(error){
      print(error);
      AttendanceException(message: error.message);

    }
} 


  Future<Attendancestats?> getStudentAttendanceStats(String courseId, String studentId) async{
    print("i am in getstas controller with");
    print(courseId);
    print("and");
    print(studentId);
    try{
      final state=await _attendanceRepository.getStudentAttendanceStats(courseId, studentId);
      return state;

    }on AttendanceException catch(error){
      print(error);
      AttendanceException(message: error.message);

    }
  }
 

  Future<String> generateQrCode(String courseId) async {
    // Skip if already generating or same course requested
    if (_isGenerating || _lastCourseId == courseId) {
      return state.value ?? '';
    }

    _isGenerating = true;
    _lastCourseId = courseId;
    state = const AsyncValue.loading();

    try {
      final qrCode = await _attendanceRepository.generateQrCode(courseId);
      state = AsyncValue.data(qrCode);
      return qrCode;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _lastCourseId = null; // Reset on error
      rethrow;
    } finally {
      _isGenerating = false;
    }
  }

  Future<bool> scanQrCode(String token, String classId) async {
    if (_isGenerating) return false;
    
    _isGenerating = true;
    state = const AsyncValue.loading();

    try {
      final result = await _attendanceRepository.scanQrCode(token, classId);
      state = AsyncValue.data(result.toString());
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    } finally {
      _isGenerating = false;
    }
  }

  void resetState() {
    state = const AsyncValue.data('');
    _lastCourseId = null;
  }
}

// AttendanceController Provider with correct types
final attendanceControllerProvider = StateNotifierProvider<AttendanceController, AsyncValue<String>>((ref) {
  final attendanceRepository = ref.watch(attendanceRepositoryProvider);
  return AttendanceController(attendanceRepository);
});

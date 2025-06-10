import 'package:crossplatform_flutter/core/errors/AttendanceError.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/infrastructure/attendance/attendance_repository.dart';

// AttendanceController with proper state typing
class AttendanceController extends StateNotifier<AsyncValue<String>> {
  final AttendanceRepository _attendanceRepository;
  bool _isGenerating = false;
  String? _lastCourseId; // Track last generated course

  AttendanceController(this._attendanceRepository) : super(const AsyncValue.data(''));

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

// AttendanceController Provider
final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AsyncValue<String>>((ref) {
  final attendanceRepository = ref.watch(attendanceRepositoryProvider);
  return AttendanceController(attendanceRepository);
});

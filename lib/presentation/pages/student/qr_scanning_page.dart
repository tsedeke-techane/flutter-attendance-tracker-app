// LOGIC: Handles QR scanning and attendance submission
import 'dart:async';
import 'dart:convert';
import 'package:crossplatform_flutter/application/attendance/attendance_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

mixin QrScannerLogic<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanning = true;

  Future<void> handleBarcode(BarcodeCapture barcodeCapture) async {
    if (!_isScanning) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final value = barcodes.first.rawValue;
      if (value != null) {
        setState(() => _isScanning = false);
        print("Scanned value: $value");

        try {
          if (value.startsWith('{')) {
            final map = jsonDecode(value) as Map<String, dynamic>;
            final token = map['token'] as String?;
            final classId = map['classId'] as String?;

            if (token == null || classId == null) {
              showError("Invalid QR code format");
              setState(() => _isScanning = true);
              return;
            }

            final state = ref.read(attendanceControllerProvider.notifier);
            final scanSuccess = await state.scanQrCode(token, classId);

            if (scanSuccess) {
              showSuccess("Attendance marked successfully!");
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) context.go('/student-dashboard');
              });
            } else {
              showError("Failed to mark attendance");
              setState(() => _isScanning = true);
            }
          } else {
            showError("QR code doesn't contain valid data");
            setState(() => _isScanning = true);
          }
        } catch (e) {
          showError("Invalid QR code data");
          setState(() => _isScanning = true);
          print('Failed to decode JSON: $e');
        }
      }
    }
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

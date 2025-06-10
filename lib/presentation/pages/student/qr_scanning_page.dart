import 'dart:async';
import 'dart:convert';
import 'package:crossplatform_flutter/application/attendance/attendance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanningPage extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;
  final String teacherName;
  const QrScanningPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.teacherName,
  });

  @override
  ConsumerState<QrScanningPage> createState() => _QrScanningPageState();
}

class _QrScanningPageState extends ConsumerState<QrScanningPage> {
  late final MobileScannerController controller;
  bool _isScanning = true;
  final _scanBoxSize = 250.0;
  // Removed scan initialization here because 'ref' is not accessible in initializers.


  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }
  

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

 void _handleBarcode(BarcodeCapture barcodeCapture) async {
  if (!_isScanning) return;

  final barcodes = barcodeCapture.barcodes;
  if (barcodes.isNotEmpty) {
    final value = barcodes.first.rawValue;
    if (value != null) {
      setState(() => _isScanning = false);
      print("Scanned value: $value");

      try {
        if (value.startsWith('{')) {
          try {
            final map = Map<String, dynamic>.from(jsonDecode(value) as Map<String, dynamic>);
            final token = map['token'] as String?;
            final classId = map['classId'] as String?;
            
            if (token == null || classId == null) {
              _showError("Invalid QR code format");
              setState(() => _isScanning = true);
              return;
            }

            print('Token: $token, ClassId: $classId');
            
            final state = ref.read(attendanceControllerProvider.notifier);
            final scanSuccess = await state.scanQrCode(token, classId);
            print("the scan res");
            print(scanSuccess);
            
            if (scanSuccess) {
              _showSuccess("Attendance marked successfully!");
              // Optionally navigate back after success
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) context.go('/student-dashboard');
              });
            } else {
              _showError("Failed to mark attendance");
              setState(() => _isScanning = true);
            }
          } catch (e) {
            _showError("Invalid QR code data");
            setState(() => _isScanning = true);
            print('Failed to decode JSON: $e');
          }
        } else {
          _showError("QR code doesn't contain valid data");
          setState(() => _isScanning = true);
        }
      } catch (e) {
        _showError("Error processing QR code");
        setState(() => _isScanning = true);
        print('Failed to parse QR code: $e');
      }
    }
  }
}

void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
   
   

    return Scaffold(
       backgroundColor: const Color(0xFF0A1A2F),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 80,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business, size: 30),
                  ),
                ],
              ),
            ),
            
            // Scanner Box
            Expanded(
              
              
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                       IconButton(onPressed: (){context.go('/student-dashboard');}, icon: Icon(Icons.arrow_back_ios)),
                        Text(widget.courseName, style: TextStyle(fontSize: 30))
                      ],),
                      Text("Teacher: ${widget.teacherName}"),
                      SizedBox(height: 40),
                  
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Instruction text
                            const Text(
                              'Align QR code within the frame',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 50),
                            
                            // Scanner container
                            Container(
                              width: _scanBoxSize,
                              height: _scanBoxSize,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.white,
                                  child: MobileScanner(
                                    controller: controller,
                                    onDetect: _handleBarcode,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text('Simple scan the QR code when you enter class\n                   to mark your attendance \n                      automatically!'),
                            )
                            
                            // Cancel button
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

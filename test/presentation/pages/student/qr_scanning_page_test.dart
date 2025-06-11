import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:crossplatform_flutter/presentation/pages/student/qr_scanning_page.dart';
import 'package:crossplatform_flutter/application/attendance/attendance_controller.dart';
import 'package:crossplatform_flutter/infrastructure/attendance/attendance_repository.dart';

class MockAttendanceController extends StateNotifier<AsyncValue<String>> with Mock implements AttendanceController {
  MockAttendanceController() : super(const AsyncData(''));
  
  @override
  Future<bool> scanQrCode(String token, String classId) async {
    return true;
  }
}

class MockAttendanceRepository extends Mock implements AttendanceRepository {}
class MockMobileScannerController extends Mock implements MobileScannerController {}
class MockBarcodeCapture extends Mock implements BarcodeCapture {}
class MockBarcode extends Mock implements Barcode {}

void main() {
  late MockAttendanceController mockAttendanceController;
  late MockAttendanceRepository mockAttendanceRepository;
  late MockMobileScannerController mockScannerController;

  setUp(() {
    mockAttendanceController = MockAttendanceController();
    mockAttendanceRepository = MockAttendanceRepository();
    mockScannerController = MockMobileScannerController();
    
    // Initialize with empty state
    mockAttendanceController.state = const AsyncData('');
  });

  Widget createWidgetUnderTest({
    required String courseId,
    required String courseName,
    required String teacherName,
  }) {
    return ProviderScope(
      overrides: [
        attendanceRepositoryProvider.overrideWithValue(mockAttendanceRepository),
        attendanceControllerProvider.overrideWithProvider(
          StateNotifierProvider<AttendanceController, AsyncValue<String>>((ref) => mockAttendanceController)
        ),
      ],
      child: MaterialApp(
        home: QrScanningPage(
          courseId: courseId,
          courseName: courseName,
          teacherName: teacherName,
        ),
      ),
    );
  }

  testWidgets('QrScanningPage shows course information', (WidgetTester tester) async {
   
    // Act
    await tester.pumpWidget(
      createWidgetUnderTest(
        courseId: 'course123',
        courseName: 'Math',
        teacherName: 'John Doe',
      ),
    );

    // Assert
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('Teacher: John Doe'), findsOneWidget);
    expect(find.text('Align QR code within the frame'), findsOneWidget);
  });

  testWidgets('QrScanningPage shows scanner when not in loading state', (WidgetTester tester) async {
    
    // Arrange
    mockAttendanceController.state = const AsyncData('');

    // Act
    await tester.pumpWidget(
      createWidgetUnderTest(
        courseId: 'course123',
        courseName: 'Math',
        teacherName: 'John Doe',
      ),
    );

    // Assert
    expect(find.byType(MobileScanner), findsOneWidget);
  });

  testWidgets('QrScanningPage has a back button', (WidgetTester tester) async {
    
    // Act
    await tester.pumpWidget(
      createWidgetUnderTest(
        courseId: 'course123',
        courseName: 'Math',
        teacherName: 'John Doe',
      ),
    );

    // Assert
    expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
  });
}

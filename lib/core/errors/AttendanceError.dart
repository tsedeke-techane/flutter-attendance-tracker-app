class AttendanceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  AttendanceException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'AttendanceException: $message (Status: $statusCode)';
    }
    return 'AttendanceException: $message';
  }
}

// Specific error types
class QrGenerationException extends AttendanceException {
  QrGenerationException({
    String message = 'Failed to generate QR code',
    int? statusCode,
    dynamic error,
  }) : super(message: message, statusCode: statusCode, error: error);
}

class QrScanningException extends AttendanceException {
  QrScanningException({
    String message = 'Failed to scan QR code',
    int? statusCode,
    dynamic error,
  }) : super(message: message, statusCode: statusCode, error: error);
}

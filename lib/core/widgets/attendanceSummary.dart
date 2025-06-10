import 'package:crossplatform_flutter/core/widgets/BooleanStrikeGrid.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';
import 'package:flutter/material.dart';

class AttendanceDetailsModal extends StatelessWidget {
  final User student;
  final String courseId;
  final double attendancePercentage;
  final Future<Attendancestats?> attendanceFuture;

  const AttendanceDetailsModal({
    super.key,
    required this.student,
    required this.courseId,
    required this.attendancePercentage,
    required this.attendanceFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Attendancestats?>(
      future: attendanceFuture,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.note),
                      SizedBox(width: 8),
                      Text("Attendance Summary",
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Student Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: ${student.ID}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Attendance Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAttendanceStat(
                    context,
                    "Present",
                    '$attendancePercentage%',
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildAttendanceStat(
                    context,
                    "Absent",
                    '${100 - attendancePercentage}%',
                    Colors.red,
                    Icons.cancel,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              // Handle error state
              else if (snapshot.hasError)
                Center(
                  child: Text(
                    'Error loading attendance data',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                )
              // Handle null or empty data
              else if (snapshot.data == null)
                const Center(child: Text('No attendance data available'))
              // Show data when available
              else
                BooleanStrikeGrid(
                  data: snapshot.data!.attendanceList,
                  size: 20,
                  gap: 4,
                  presentColor: Colors.green[400]!,
                  absentColor: Colors.red[400]!,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceStat(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

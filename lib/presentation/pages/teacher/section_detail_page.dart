import 'package:crossplatform_flutter/application/attendance/attendance_controller.dart';
import 'package:crossplatform_flutter/core/widgets/BooleanStrikeGrid.dart';
import 'package:crossplatform_flutter/core/widgets/attendanceSummary.dart';
import 'package:crossplatform_flutter/domain/attendance/attendanceStats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crossplatform_flutter/application/course/course_controller.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

class SectionDetailPage extends ConsumerStatefulWidget {
  final String courseId;
  const SectionDetailPage({super.key, required this.courseId});

  @override
  ConsumerState<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends ConsumerState<SectionDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  bool _showAddForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(courseStudentsProvider(widget.courseId));
    final courseAsync = ref.watch(teacherCoursesProvider);
  

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 80,
                    height: 30,
                  ),
                ],
              ),
            ),
            
            // Section info card
            courseAsync.when(
              data: (courses) => studentsAsync.when(
                data: (students) => _buildSectionInfo(students.length, widget.courseId),
                loading: () => _buildSectionInfo(0, widget.courseId),
                error: (_, __) => _buildSectionInfo(0,widget.courseId),
              ),
              loading: () => _buildSectionInfo(0,widget.courseId),
              error: (_, __) => _buildSectionInfo(0,widget.courseId),
            ),
            
            // Students List
            Expanded(
              child: studentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
                ),
                data: (students) => _buildStudentList(students, widget.courseId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionInfo(int studentCount, String courseId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
                onPressed: () => context.go('/teacher-dashboard'),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Section 1',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Total: $studentCount Students',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
            ],
          ),
           GestureDetector(
          onTap:() {context.go('/qr-generator/$courseId');},
          child: Image.asset(
            'assets/images/gg_qr.png',
           
          ),
        ),
           
        ],
      ),
    );
  }

Widget _buildStudentList(List<User> students, String courseId) {
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final attendance = student.overallStats ?? 0;
              
              return GestureDetector(
                onTap: () {
                  final attendanceNotifier = ref.read(attendanceControllerProvider.notifier);
                  final attendanceFuture = attendanceNotifier.getStudentAttendanceStats(
                    courseId, 
                    student.id
                  );

                 showModalBottomSheet(
  context: context,
  
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  backgroundColor: Colors.white,
  builder: (context) => AttendanceDetailsModal(
    student: student,
    courseId: courseId,
    attendancePercentage: attendance.toDouble(),
    attendanceFuture: attendanceFuture,
  ),
);

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${index + 1}.${student.name}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              // color: _getAttendanceColor(attendance.toDouble()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$attendance% Present',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                               
                                color: Color.fromARGB(255, 197, 202, 216),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          student.ID,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (index < students.length - 1)
                        const Divider(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        if (_showAddForm)
          _buildAddStudentForm()
        else
          _buildAddStudentButton(),
      ],
    ),
  );
}
 
  Widget _buildAddStudentButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showAddForm = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Add New Student',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddStudentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showAddForm = false;
                        _nameController.clear();
                        _idController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final success = await ref.read(teacherCoursesProvider.notifier).addStudentToCourse(
                            widget.courseId,
                            _idController.text,
                            _nameController.text,
                          );
                          
                          if (success) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Student added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            
                            // Invalidate the cache to force refresh
                            ref.invalidate(courseStudentsProvider(widget.courseId));
                            
                            setState(() {
                              _showAddForm = false;
                              _nameController.clear();
                              _idController.clear();
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                // backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Color _getAttendanceColor(double percentage) {
  //   if (percentage >= 90) return Colors.green;
  //   if (percentage >= 80) return Colors.lightGreen;
  //   if (percentage >= 60) return Colors.orange;
  //   return Colors.;
  // }
}
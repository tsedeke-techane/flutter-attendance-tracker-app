import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crossplatform_flutter/application/course/course_controller.dart';
import 'package:crossplatform_flutter/domain/course/course.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the courses from the provider
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and refresh button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 80,
                    height: 30,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      // Refresh courses
                      ref.refresh(teacherCoursesProvider);
                    },
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: coursesAsync.when(
                  data: (courses) => _buildContent(context, courses, ref),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading courses:',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.refresh(teacherCoursesProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A1A2F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddCourseDialog(context, ref);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Course> courses, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Greeting text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           
           RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1A2F),
            ),
            children: [
              TextSpan(text: 'Hi Teacher,\n'),
              TextSpan(text: 'Ready To Teach '),
              TextSpan(text: 'Today?'),
            ],
          ),
        ),
       

        ],),
       
         SizedBox(height: 24),
        // Grid of courses
        Expanded(
          child: courses.isEmpty
              ? const Center(
                  child: Text(
                    'No courses yet. Add a course to get started!',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return GestureDetector(
                      onTap: () => context.go('/section-detail/${course.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1A2F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Section: ${course.section}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                           Expanded(
  child: Row(
    children: [
      Flexible(  // Add Flexible here
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),  // Reduced padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FittedBox(  // Add FittedBox to scale down text if needed
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${course.students.length} students',
                  style: const TextStyle(color: Colors.white, fontSize: 10),  // Reduced font size
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 4),  // Reduced spacing
      Flexible(  // Add Flexible here
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),  // Reduced padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FittedBox(  // Add FittedBox
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                const Text(
                  '2 hrs',
                  style: TextStyle(color: Colors.white, fontSize: 10),  // Reduced font size
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
)
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        
      ],
    );
  }

  void _showAddCourseDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final sectionController = TextEditingController();
    final scheduleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'e.g. Physics, Mathematics',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  hintText: 'e.g. S1, 4A',
                ),
              ),
              const SizedBox(height: 16),
               TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule',
                  hintText: 'e.g. morning, evening',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: Text("Add Course"),
            onPressed: () async {
              if (nameController.text.isEmpty || sectionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }
              try{
                Navigator.pop(context);
                  
                                final result = await ref.read(teacherCoursesProvider.notifier).createCourse(
                  nameController.text,
                  sectionController.text,
                  scheduleController.text,
                );
                    
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  if (result != null) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Course created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create course'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

              }}catch(error){
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create course: ${error.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );

              }


              // try {
              //   Navigator.pop(context);
                
              //   // Show loading indicator
              //   showDialog(
              //     context: context,
              //     barrierDismissible: false,
              //     builder: (context) => const Center(
              //       child: CircularProgressIndicator(),
              //     ),
              //   );
                
              //   // final result = await ref.read(teacherCoursesProvider.notifier).createCourse(
              //   //   nameController.text,
              //   //   sectionController.text,
              //   // );
                
              //   // Close loading dialog
              //   // if (context.mounted) {
              //   //   Navigator.pop(context);
                  
              //   //   if (result != null) {
              //   //     // Show success message
              //   //     ScaffoldMessenger.of(context).showSnackBar(
              //   //       const SnackBar(
              //   //         content: Text('Course created successfully'),
              //   //         backgroundColor: Colors.green,
              //   //       ),
              //   //     );
              //   //   } else {
              //   //     // Show error message
              //   //     ScaffoldMessenger.of(context).showSnackBar(
              //   //       const SnackBar(
              //   //         content: Text('Failed to create course'),
              //   //         backgroundColor: Colors.red,
              //   //       ),
              //   //     );
              //   //   }
              //   }
              // } catch (e) {
              //   // Close loading dialog
              //   if (context.mounted) {
              //     Navigator.pop(context);
                  
              //     // Show error message
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Failed to create course: ${e.toString()}'),
              //         backgroundColor: Colors.red,
              //       ),
              //     );
              //   }
              // }
            
           
              }
  }),
        ],
      ),
    );
  }
}
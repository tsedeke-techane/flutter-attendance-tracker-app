import 'package:crossplatform_flutter/core/widgets/myTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crossplatform_flutter/application/auth/auth_controller.dart';
import 'package:crossplatform_flutter/domain/auth/user.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final passwordController = TextEditingController();
    final authController = ref.watch(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Column(
        children: [
          // Top section with logo and title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24),
            child: Column(
              children: [
                // Logo
                Image.asset(
                  'assets/images/Logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log in to record your attendance, manage\nyour records, and stay updated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom section with form (now scrollable)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Name field
                    Mytextfield(
                      controller: nameController,
                      hintText: 'Name',
                    ),
                    const SizedBox(height: 16),
                    // ID field
                    Mytextfield(
                      controller: idController,
                      hintText: 'ID',
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    Mytextfield(
                      isPassword: true,
                      controller: passwordController,
                      hintText: 'Password',
                    ),
                    const SizedBox(height: 24),
                    // Log in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          try {
                            // Call login API
                            await authController.signIn(
                              nameController.text,
                              idController.text,
                              passwordController.text,
                            );
                            
                            // Close loading dialog
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            
                            // Get user from state
                            final user = ref.read(authControllerProvider).value;
                            
                            // Navigate based on user role
                            if (context.mounted) {
                              if (user?.role == UserRole.teacher) {
                                context.go('/teacher-dashboard');
                              } else {
                                context.go('/student-dashboard');
                              }
                            }
                          } catch (e) {
                            // Close loading dialog
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            
                            // Show error message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login failed: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1A2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Log In'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sign up link
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text(
                        "I don't have an account. Sign up",
                        style: TextStyle(
                          color: Color(0xFF0A1A2F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

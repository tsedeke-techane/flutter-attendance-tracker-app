import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Dark blue top section with logo
          Container(
            color: const Color(0xFF0A1A2F),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {},
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Skip',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Column(
                  //   children: [
                  Container(
                    width: 100, // Increased from 60
                    height: 100, // Increased from 60

                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/Logo.png'),
                  ),
                  //     const SizedBox(height: 8),
                  //     const Text(
                  //       'SCANIN',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.bold,
                  //         letterSpacing: 1.2,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // White bottom section with content
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'QR Your Way In.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1A2F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Effortlessly track your attendance and stay\non top of your classes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1A2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

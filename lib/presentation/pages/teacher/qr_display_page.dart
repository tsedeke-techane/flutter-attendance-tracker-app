import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossplatform_flutter/application/attendance/attendance_controller.dart';
import 'package:go_router/go_router.dart';

class QrDisplayPage extends ConsumerWidget {
  final String courseId;
  const QrDisplayPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceControllerProvider);
    
    // Trigger QR code generation when first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceControllerProvider.notifier).generateQrCode(courseId);
    });

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
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.business, size: 30),
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: Container(
                color: Colors.white,
                child: state.when(
                  loading: () => _buildLoadingContent(),
                  error: (error, stack) => _buildErrorContent(error, ref),
                  data: (qrCode) => _buildMainContent(context, qrCode, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorContent(dynamic error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(
            'Failed to generate QR code',
            style: TextStyle(color: Colors.red[800], fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
        
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, String qrCode, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Back button and title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.go('/teacher-dashboard'),
              ),
              const Text(
                'Cyber Security',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Teacher: Senait Demisse",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 40),
          const Text(
            'Scan the QR code for attendance',
            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
          ),
          const SizedBox(height: 40),
          // QR Code Display
          _buildQrImage(qrCode),
          const SizedBox(height: 20),
          // Refresh button
         Container(child: Text("Simply scan the QR code when you enter class to mark your attendance automatically!",style: TextStyle(color: Colors.blueGrey, fontSize: 9))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

 

  Widget _buildImageError() {
    return const Column(
      children: [
        Icon(Icons.broken_image, size: 50, color: Colors.red),
        SizedBox(height: 8),
        Text('Could not display QR code', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
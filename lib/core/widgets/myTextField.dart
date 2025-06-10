import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {
  final TextEditingController? controller;
  final bool isPassword;
  final String? hintText;

  const Mytextfield({
    super.key,
    this.controller,
    this.hintText,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return    TextField(
                    controller: controller,
                    obscureText: isPassword,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
  }
}

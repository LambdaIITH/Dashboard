import 'package:dashbaord/extensions.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: controller,
          cursorColor: context.customColors.customAccentColor,
        decoration: InputDecoration(
          hintText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          filled: true,
          fillColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.1),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

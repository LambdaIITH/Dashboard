import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintProgressIndicator extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const ComplaintProgressIndicator({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            totalSteps,
            (index) {
              final isActive = index <= currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xffFE724C)
                              : (isDark ? Colors.grey[700] : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < totalSteps - 1) const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          stepTitle,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintNavigationButtons extends StatelessWidget {
  final bool isDark;
  final int currentStep;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final bool isLoading;

  const ComplaintNavigationButtons({
    super.key,
    required this.isDark,
    required this.currentStep,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onPrevious,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xffFE724C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffFE724C),
                ),
              ),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: canGoNext
                ? (currentStep == 3
                    ? (isLoading ? null : onSubmit)
                    : (isLoading ? null : onNext))
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xffFE724C),
              disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading && currentStep == 3
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    currentStep == 3 ? 'Submit' : 'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

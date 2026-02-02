import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyComplaintsView extends StatelessWidget {
  final Color textColor;

  const EmptyComplaintsView({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No complaints yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted complaints will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

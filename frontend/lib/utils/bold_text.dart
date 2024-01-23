import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoldText extends StatelessWidget {
  const BoldText({
    super.key,
    required this.text,
    required this.color,
    this.size = 22,
    this.limit = 10,
  });

  final String text;
  final Color color;
  final double size;
  final int limit;

  double getResponsiveFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width <= 320) {
      return size * 0.8;
    } else if (width <= 420) {
      return size * 0.9;
    }
    return size;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: limit,
        style: GoogleFonts.inter(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

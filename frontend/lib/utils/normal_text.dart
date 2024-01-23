import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NormalText extends StatelessWidget {
  const NormalText({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.size = 18,
    this.limit = 10,
    this.center = false,
  });

  final String text;
  final Color color;
  final double size;
  final int limit;
  final bool center;

  double getResponsiveFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width <= 320) {
      return size * 0.8; // Return a reduced font size for smaller screens
    } else if (width <= 420) {
      return size * 0.9; // Return a slightly reduced font size
    }
    return size; // Return the default font size for larger screens
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      maxLines: limit,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.montserrat(
        color: color,
        fontSize: getResponsiveFontSize(context),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCardNoOptions extends StatelessWidget {
  final String title;
  final dynamic child;
  final bool isimage;
  final void Function() onTap;
  const HomeCardNoOptions({
    super.key,
    required this.title,
    required this.child,
    required this.onTap,
    this.isimage = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: isimage ? 140 : 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
              offset: Offset(0, 4), // Offset in the x, y direction
              blurRadius: 10.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: 15,
              left: 18,
              child: Text(
                title,
                style: GoogleFonts.inter().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            isimage
                ? Positioned(
                    bottom: -13,
                    right: -7,
                    child: SvgPicture.asset(
                      child,
                      width: min(0.5 * screenWidth, 200),
                    ),
                  )
                : Positioned(
                    bottom: 13,
                    child: SizedBox(width: 350, child: child),
                  ),
          ],
        ),
      ),
    );
  }
}

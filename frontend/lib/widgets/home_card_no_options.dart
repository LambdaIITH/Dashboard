import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCardNoOptions extends StatelessWidget {
  final String title;
  final dynamic child;
  final bool isLnF;
  final bool isComingSoon;
  final void Function() onTap;
  const HomeCardNoOptions(
      {super.key,
      required this.title,
      required this.child,
      required this.onTap,
      this.isLnF = false,
      this.isComingSoon = true});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        height: 140,
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
        child: Stack(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 15,
                  left: 18,
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                isLnF
                    ? Positioned(
                        bottom: -13,
                        right: -7,
                        child: SvgPicture.asset(
                          child,
                          width: min(0.42 * screenWidth, 200),
                        ),
                      )
                    : Positioned(
                        bottom: -13,
                        right: -7,
                        child: SvgPicture.asset(
                          child,
                          width: min(0.5 * screenWidth, 200),
                        ),
                      )
              ],
            ),
            if (isComingSoon)
              Container(
                // width: double.infinity,
                // height: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
                child: Center(
                    child: SizedBox(
                        height: 120,
                        child: Image.asset(
                          "assets/icons/comingsoon.png",
                        ))),
              )
          ],
        ),
      ),
    );
  }
}

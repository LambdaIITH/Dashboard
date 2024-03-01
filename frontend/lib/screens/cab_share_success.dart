import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabShareSuccess extends StatelessWidget {
  const CabShareSuccess({Key? key}) : super(key: key);
  final String name = "John Doe";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/cab-add-success.png",
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 35),
            Text(
              "You are sharing a cab with $name",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xff272D2F),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "They will be notified",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: const Color(0xff272D2F),
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

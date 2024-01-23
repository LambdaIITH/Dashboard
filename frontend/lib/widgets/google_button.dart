import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomGoogleButton extends StatelessWidget {
  const CustomGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffFE724C),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
          //TODO: handle login route
        },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/google.png",
                  height: 36,
                  width: 36,
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  child: Text(
                    "Continue with Google",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff454545),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

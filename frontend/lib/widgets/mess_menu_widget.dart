import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart';

class ShowMessMenu extends StatelessWidget {
  final String whichMeal;
  final String time;
  final List meals;
  const ShowMessMenu(
      {super.key,
      required this.whichMeal,
      required this.meals,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xffFBFBFB),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xff000000).withOpacity(0.25),
                  offset: const Offset(
                    0.0,
                    8.0,
                  ),
                  blurRadius: 21.0,
                  spreadRadius: 0.0)
            ]),
        child: RoundedExpansionTile(
          trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
          rotateTrailing: true,
          duration: const Duration(milliseconds: 400),
          title: Padding(
            padding: const EdgeInsets.all(9),
            child: RichText(
              text: TextSpan(
                text: whichMeal,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '\n$time',
                    style: GoogleFonts.inter(
                      color: const Color(0xff4D4D4D),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          children: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 0, 9, 3),
                child: Text(
                  messMenu(),
                  style: GoogleFonts.inter(
                    color: const Color(0xff292929),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String messMenu() {
    String res = '';
    for (int i = 0; i < meals.length; i++) {
      res += meals.elementAt(i) + ',\n';
    }
    return res;
  }
}

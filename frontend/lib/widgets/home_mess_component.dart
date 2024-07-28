import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart';

class HomeMessMenu extends StatelessWidget {
  final String whichMeal;
  final String time;
  final List<String> meals;
  final List<String> extras;
  const HomeMessMenu({
    super.key,
    required this.whichMeal,
    required this.meals,
    required this.time,
    required this.extras,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 5),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff000000).withOpacity(0.25),
              offset: const Offset(
                0,
                1,
              ),
              blurRadius: 1.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: RoundedExpansionTile(
          trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
          rotateTrailing: true,
          duration: const Duration(milliseconds: 400),
          title: Padding(
            padding: const EdgeInsets.all(2),
            child: RichText(
              text: TextSpan(
                text: whichMeal,
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '\n$time',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color,
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
                padding: const EdgeInsets.fromLTRB(24, 0, 9, 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: messMenu(meals, context),
                      ),
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.labelLarge?.color,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Extras:',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.labelLarge?.color,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: messMenu(extras, context),
                      ),
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.labelLarge?.color,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> messMenu(List<String> data, BuildContext context) {
    List<TextSpan> spans = [];
    for (int i = 0; i < data.length; i++) {
      spans.add(
        TextSpan(
          text: '${i + 1}. ',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 180, 180, 180) :  const Color.fromARGB(255, 69, 69, 69),
          )
        ),
      );
      spans.add(TextSpan(text: '${data[i]}\t\t'));
    }
    spans.add(const TextSpan(text: '\n'));
    return spans;
  }
}

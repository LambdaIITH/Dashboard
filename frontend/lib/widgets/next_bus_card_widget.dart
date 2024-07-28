import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dashbaord/utils/svg_icon.dart';
import 'package:google_fonts/google_fonts.dart';

class NextBusCard extends StatelessWidget {
  final String from;
  final String destination;
  final String waitingTime;
  final bool isEv;

  const NextBusCard(
      {super.key,
      required this.from,
      required this.destination,
      required this.waitingTime,
      this.isEv = true});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final textColor =
        Theme.of(context).textTheme.titleLarge?.color ?? Colors.black;
    // TODO: Use Fractionally sized box later
    // Calculates cardsize by taking screenWidth and subtracting padding
    double cardWidth = screenWidth - 78;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Card(
        elevation: 3,
        color: Theme.of(context).textTheme.titleMedium?.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).textTheme.titleMedium?.color,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color: Colors.black,width: 1.3),
          ),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Stack(children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,spaceBetween
              children: [
                SizedBox(
                  width: cardWidth * 0.69,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12.0),
                      Text(
                        'In next',
                        style: GoogleFonts.inter(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                            letterSpacing: -0.2),
                      ),
                      Text(
                        waitingTime,
                        style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              from,
                              style: GoogleFonts.inter(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: const SvgIcon("assets/icons/arrow.svg"),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              destination,
                              style: GoogleFonts.inter(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: min(cardWidth * 0.27, 150),
                  child: Image.asset(
                      isEv ? "assets/icons/ev.png" : "assets/icons/bus.png"),
                ),
                const SizedBox(
                  width: 12,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: Alignment.topRight,
                  width: 40,
                  height: 20,
                  // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                      color: isEv
                          ? const Color(0xff0FBF00)
                          : const Color(0xff8850FF),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12))),
                  child: Center(
                    child: Text(
                      isEv ? "ev" : "bus",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

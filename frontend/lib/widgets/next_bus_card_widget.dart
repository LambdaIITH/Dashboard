import 'package:flutter/material.dart';
import 'package:frontend/utils/svg_icon.dart';
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

    // TODO: Use Fractionally sized box later
    // Calculates cardsize by taking screenWidth and subtracting padding
    double cardWidth = screenWidth - 78;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color: Colors.black,width: 1.3),
          ),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          // height: 141.0,
          child: Stack(children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,spaceBetween
              children: [
                SizedBox(
                  width: cardWidth * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12.0),
                      Text(
                        'In next',
                        style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff6A6A6A),
                            letterSpacing: -0.2),
                      ),
                      Text(
                        waitingTime,
                        style: GoogleFonts.inter(
                            color: const Color(0xff6A6A6A),
                            fontSize: 25.0,
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
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                color: const Color(0xff6A6A6A),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            child: SvgIcon("assets/icons/arrow.svg"),
                          ),
                          // const Icon(
                          //   Icons.arrow_forward_rounded,
                          //   size: 22,
                          // ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              destination,
                              style: GoogleFonts.inter(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                color: const Color(0xff6A6A6A),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
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
                  width: cardWidth * 0.3,
                  child: Image.asset(
                      isEv ? "assets/icons/ev.png" : "assets/icons/bus.png"),
                ),
                const SizedBox(width: 8,)
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
                      color: isEv ? Color(0xff0FBF00) : Color(0xff8850FF),
                      borderRadius: BorderRadius.only(
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

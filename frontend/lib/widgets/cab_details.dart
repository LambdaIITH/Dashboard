import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabCard extends StatefulWidget {
  const CabCard({super.key});

  @override
  State<CabCard> createState() => _CabCardState();
}

class _CabCardState extends State<CabCard> {
  bool _isExpanded = false;
  String note =
      "If anyone is travelling on same date and time from RGIA to IITH can contact me";
  String date = "Wed, 12th May 2021";
  String startTime = "01:00PM";
  String endTime = "02:00PM";
  String id = "RD00BGSF11001";
  String availableSeats = "2";
  String startLocation = "RGIA";
  String endLocation = "IITH";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(51, 51, 51, 0.10),
              offset: Offset(0, 8), // Offset in the x, y direction
              blurRadius: 21.0, // Blur radius
              spreadRadius: 0.0, // Spread radius
            ),
          ],
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        id,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Available Seats  ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffADADAD),
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: availableSeats,
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Text(
                                startLocation,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffADADAD),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              const Icon(
                                Icons.arrow_forward,
                                color: Color(0xffADADAD),
                                size: 20,
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                endLocation,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffADADAD),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Column(
                            children: [
                              Text(
                                date,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffADADAD),
                                ),
                              ),
                              const SizedBox(width: 2.0),
                              Text(
                                "$startTime - $endTime",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffADADAD),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _isExpanded
                          ? const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.black,
                              size: 50,
                            )
                          : const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                              size: 50,
                            ),
                    )
                  ],
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: _isExpanded,
                child: Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[200],
                          ),
                          child: Text(
                            "Note: $note",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(254, 114, 76, 0.70),
                              textStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 0.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text("Join Cab"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

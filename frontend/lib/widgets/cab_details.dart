import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabCard extends StatelessWidget {
  const CabCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "01:00 pm",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff454545),
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Available Seats  ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '2',
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
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    "QRST",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffADADAD),
                    ),
                  ),
                  Text(
                    "BYD321321",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffADADAD),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(51, 51, 51, 0.10),
                          offset: Offset(0, 2), // Offset in the x, y direction
                          blurRadius: 5.0, // Blur radius
                          spreadRadius: 0.0, // Spread radius
                        ),
                      ],
                      // borderRadius: BorderRadius.circular(6.0),
                      // color: Colors.white,
                    ),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(254, 114, 76, 0.70),
                        textStyle: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 0.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text("Share Cab"),
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow:const  [
                        BoxShadow(
                          color: Color.fromRGBO(51, 51, 51, 0.10),
                          offset: Offset(0, 8), // Offset in the x, y direction
                          blurRadius: 25.0, // Blur radius
                          spreadRadius: 1.0, // Spread radius
                        ),
                      ],
                      borderRadius: BorderRadius.circular(50.0),
                      // color: Colors.black,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(254, 114, 76, 0.70),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.call),
                        color: Colors.black,
                        iconSize: 22.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

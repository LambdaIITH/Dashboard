import 'package:flutter/material.dart';
import 'package:frontend/screens/bus_timings_screen.dart';
import 'package:frontend/utils/normal_text.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenBusTimings extends StatelessWidget {
  const HomeScreenBusTimings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const BusTimingsScreen()),
      ),
      child: Container(
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18, top: 15),
                child: Text(
                  'Bus Timings',
                  style: GoogleFonts.inter().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            getBusCard('Main Gate', 'Hostel Circle', '5 min', context),
            const SizedBox(height: 10),
            getBusCard('Hostel Circle', 'Main Gate', '5 min', context),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Container getBusCard(
      String from, String to, String waitTime, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffFBFBFB),
        borderRadius: BorderRadius.circular(10),
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
      child: Row(
        children: [
          SizedBox(
            // width: 0.3 * screenWidth,
            child: NormalText(text: from),
          ),
          const Icon(Icons.arrow_forward_rounded),
          SizedBox(width: 0.02 * screenWidth),
          NormalText(text: to),
          const Spacer(),
          NormalText(
            text: waitTime,
            size: 14,
            color: const Color(0xff404040),
          ),
        ],
      ),
    );
  }
}

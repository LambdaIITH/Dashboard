import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NextBusCard extends StatelessWidget {
  final String from;
  final String destinantion;
  final String waitingTime;

  const NextBusCard(
      {super.key, required this.from, required this.destinantion, required this.waitingTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // border: Border.all(color: Colors.black,width: 1.3),
          ),
          alignment: Alignment.center,
          width: double.infinity,
          // height: 141.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const FaIcon(
              //   CupertinoIcons.bus,
              //   size: 30,
              // ),
              const SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      from,
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 22,),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      destinantion,
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, 
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12.0,),

              Text(
                'in Next',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E5D5D),
                  letterSpacing: -0.2
                ),
              ),

              Text(
                waitingTime,
                style: GoogleFonts.inter(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2
                ),
              ),

              const SizedBox(height: 6,)

            ],
          ),
        ),
      ),
    );
  }
}

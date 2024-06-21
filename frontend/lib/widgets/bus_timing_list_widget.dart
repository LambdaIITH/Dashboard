import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusTimingList extends StatelessWidget {
  final String from;
  final String destinantion;
  final List timings;
  const BusTimingList({super.key,required this.from,required this.destinantion,required this.timings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black,width: 1.1),
        color: const Color.fromARGB(102, 229, 229, 229)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6.0,),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      from,
                      style: GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 16,),
                  Flexible(
                    child: Text(
                      destinantion,
                      style: GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, 
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6.0,),

        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: timings.length,
            itemBuilder: (context,index){
        
            return Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                child: Text(
                  timings[index],
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2
                  ),
                ),
              ),
            );
          }),
        )
          
          

      ]),
    );
  }
}
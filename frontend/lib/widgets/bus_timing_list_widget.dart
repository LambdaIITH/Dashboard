import 'package:dashbaord/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusTimingList extends StatelessWidget {
  final String from;
  final String destination;
  final Map<String, int> timings;

  const BusTimingList({
    super.key,
    required this.from,
    required this.destination,
    required this.timings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: context.customColors.customBusScheduleColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  from,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.displayLarge?.color,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16),
              Flexible(
                child: Text(
                  destination,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.displayLarge?.color,
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
          const SizedBox(height: 6.0),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: timings.length,
              itemBuilder: (context, index) {
                String key = timings.keys.elementAt(index);
                int value = timings[key] ?? 0;
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    value == 1 ? '$key*' : key, // Display key and value
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.displayLarge?.color,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/screens/bus_timings_screen.dart';
import 'package:frontend/utils/bus_schedule.dart';
import 'package:frontend/utils/normal_text.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenBusTimings extends StatefulWidget {
  const HomeScreenBusTimings({super.key, required this.busSchedule});
  final BusSchedule? busSchedule;

  @override
  State<HomeScreenBusTimings> createState() => _HomeScreenBusTimingsState();
}

class _HomeScreenBusTimingsState extends State<HomeScreenBusTimings> {
  int getNextOneBusesFromMaingate() {
    if (widget.busSchedule == null) return -1;

    List<String> allBuses = widget.busSchedule!.toIITH;
    DateTime now = DateTime.now();

    List<DateTime> busTimes = allBuses.map((time) {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();

    List<DateTime> nextBuses =
        busTimes.where((busTime) => busTime.isAfter(now)).toList();
    nextBuses.sort();

    if (nextBuses.isNotEmpty) {
      Duration difference = nextBuses.first.difference(
          DateTime(now.year, now.month, now.day, now.hour, now.minute));
      return difference.inMinutes;
    } else {
      return -1;
    }

    // List<NextBusModel> nextTwoBuses = nextBuses.take(1).map((busTime) {
    // Duration difference = busTime.difference(
    //     DateTime(now.year, now.month, now.day, now.hour, now.minute));
    //   int minutes = difference.inMinutes;
    //   String formattedDifference = "$minutes min";
    //   return NextBusModel(
    //     isFromIITH: false,
    //     time:
    //         "${busTime.hour.toString().padLeft(2, '0')}:${busTime.minute.toString().padLeft(2, '0')}",
    //     timeDifference: formattedDifference,
    //   );
    // }).toList();

    // return nextTwoBuses;
  }

  int getNextOneBusesFromHostelCircle() {
    if (widget.busSchedule == null) return -1;

    List<String> allBuses = widget.busSchedule!.fromIITH;
    DateTime now = DateTime.now();

    List<DateTime> busTimes = allBuses.map((time) {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();

    List<DateTime> nextBuses =
        busTimes.where((busTime) => busTime.isAfter(now)).toList();
    nextBuses.sort();

    if (nextBuses.isNotEmpty) {
      Duration difference = nextBuses.first.difference(
          DateTime(now.year, now.month, now.day, now.hour, now.minute));
      return difference.inMinutes;
    } else {
      return -1;
    }

    // List<NextBusModel> nextTwoBuses = nextBuses.take(1).map((busTime) {
    //   Duration difference = busTime.difference(
    //       DateTime(now.year, now.month, now.day, now.hour, now.minute));
    //   int minutes = difference.inMinutes;
    //   String formattedDifference = "$minutes min";
    //   return NextBusModel(
    //     isFromIITH: true,
    //     time:
    //         "${busTime.hour.toString().padLeft(2, '0')}:${busTime.minute.toString().padLeft(2, '0')}",
    //     timeDifference: formattedDifference,
    //   );
    // }).toList();

    // return nextTwoBuses;
  }

  void updateNextBuses() {
    int maingateBuses = getNextOneBusesFromMaingate();
    int hostelCircleBuses = getNextOneBusesFromHostelCircle();

    setState(() {
      busOneTime = maingateBuses;
      busTwoTime = hostelCircleBuses;
    });
  }

  Timer? _timer;
  int busOneTime = -1;
  int busTwoTime = -1;

  @override
  void initState() {
    super.initState();
    updateNextBuses();
    setInitialTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setInitialTimer() {
    DateTime now = DateTime.now();
    int secondsUntilNextMinute = 60 - now.second;
    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      updateNextBuses();
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        updateNextBuses();
      });
    });
  }

  Widget noBusses(String msg, BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.busSchedule == null) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  BusTimingsScreen(busSchedule: widget.busSchedule!)),
        );
      },
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
            Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.busSchedule == null) {
      return noBusses("Failed to fetch bus schedule", context);
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => BusTimingsScreen(
                  busSchedule: widget.busSchedule!,
                )),
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
            if (busOneTime != -1)
              getBusCard(
                  'Main Gate', 'Hostel Circle', '$busOneTime min', context),
            const SizedBox(height: 10),
            if (busTwoTime != -1)
              getBusCard(
                  'Hostel Circle', 'Main Gate', '$busTwoTime min', context),
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

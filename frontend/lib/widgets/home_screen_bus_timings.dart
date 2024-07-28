import 'dart:async';

import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/screens/bus_timings_screen.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenBusTimings extends StatefulWidget {
  const HomeScreenBusTimings({super.key, required this.busSchedule});
  final BusSchedule? busSchedule;

  @override
  State<HomeScreenBusTimings> createState() => _HomeScreenBusTimingsState();
}

class _HomeScreenBusTimingsState extends State<HomeScreenBusTimings> {
  List<int> getNextOneBusesFromMaingate() {
    if (widget.busSchedule == null) return [-1, -1];
    Map<String, int> allBuses =
        Map<String, int>.from(widget.busSchedule!.toIITH);
    DateTime now = DateTime.now();

    List<MapEntry<DateTime, int>> busTimes = allBuses.entries
        .map((entry) {
          List<String> parts = entry.key.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          DateTime time = DateTime(now.year, now.month, now.day, hour, minute);
          if (time.isBefore(now)) {
            time = time.add(const Duration(days: 1));
          }
          return MapEntry(time, entry.value);
        })
        .where((entry) => entry.key.isAfter(now))
        .toList();

    busTimes.sort((a, b) => a.key.compareTo(b.key));

    if (busTimes.isNotEmpty) {
      DateTime nextBusTime = busTimes.first.key;
      int mode = busTimes.first.value;
      Duration difference = nextBusTime.difference(
          DateTime(now.year, now.month, now.day, now.hour, now.minute));
      return [
        difference.inMinutes,
        mode
      ]; // First element is time, second is mode
    } else {
      return [-1, -1];
    }
  }

  List<int> getNextOneBusesFromHostelCircle() {
    if (widget.busSchedule == null) return [-1, -1];
    Map<String, int> allBuses =
        Map<String, int>.from(widget.busSchedule!.fromIITH);
    DateTime now = DateTime.now();

    List<MapEntry<DateTime, int>> busTimes = allBuses.entries
        .map((entry) {
          List<String> parts = entry.key.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          DateTime time = DateTime(now.year, now.month, now.day, hour, minute);
          if (time.isBefore(now)) {
            time = time.add(const Duration(days: 1));
          }
          return MapEntry(time, entry.value);
        })
        .where((entry) => entry.key.isAfter(now))
        .toList();

    busTimes.sort((a, b) => a.key.compareTo(b.key));

    if (busTimes.isNotEmpty) {
      DateTime nextBusTime = busTimes.first.key;
      int mode = busTimes.first.value;
      Duration difference = nextBusTime.difference(
          DateTime(now.year, now.month, now.day, now.hour, now.minute));
      return [difference.inMinutes, mode];
    } else {
      return [-1, -1];
    }
  }

  void updateNextBuses() {
    List<int> maingateBuses = getNextOneBusesFromMaingate();
    List<int> hostelCircleBuses = getNextOneBusesFromHostelCircle();

    setState(() {
      busOneTime = maingateBuses[0];
      busTwoTime = hostelCircleBuses[0];
      firstMode = maingateBuses[1];
      secondMode = hostelCircleBuses[1];
    });
  }

  Timer? _timer;
  int busOneTime = -1;
  int busTwoTime = -1;
  int firstMode = 0;
  int secondMode = 0;

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
        Navigator.push(
            context,
            CustomPageRoute(
                child: BusTimingsScreen(busSchedule: widget.busSchedule!)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.customColors.customContainerColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.customColors.customShadowColor, // Shadow color
              offset: const Offset(0, 4), // Offset in the x, y direction
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
                  style: GoogleFonts.inter(
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

    if (busOneTime == -1 && busTwoTime == -1) {
      return noBusses("No upcoming buses available", context);
    }

    return InkWell(
      onTap: () => Navigator.push(
          context,
          CustomPageRoute(
              child: BusTimingsScreen(busSchedule: widget.busSchedule!))),
      child: Container(
        decoration: BoxDecoration(
          color: context.customColors.customContainerColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.customColors.customShadowColor,
              offset: const Offset(0, 4), // Offset in the x, y direction
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
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (busOneTime != -1)
              getBusCard(
                  'Main Gate',
                  firstMode == 0 ? 'Hostel Circle' : 'Hostel Circle*',
                  '$busOneTime min',
                  context),
            const SizedBox(height: 10),
            if (busTwoTime != -1)
              getBusCard(
                  'Hostel Circle',
                  secondMode == 0 ? 'Main Gate' : 'Main Gate*',
                  '$busTwoTime min',
                  context),
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
        color: Theme.of(context).cardColor,
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
            color: Theme.of(context).textTheme.titleSmall?.color,
          ),
        ],
      ),
    );
  }
}

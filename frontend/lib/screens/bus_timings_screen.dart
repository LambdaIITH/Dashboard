import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/utils/bus_schedule.dart';
import 'package:frontend/widgets/bus_timing_list_widget.dart';
import 'package:frontend/widgets/next_bus_card_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/analytics_service.dart';

class BusTimingsScreen extends StatelessWidget {
  const BusTimingsScreen({super.key, required this.busSchedule});
  final BusSchedule busSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Timings',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            )),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: BusSchedulePage(
            busSchedule: busSchedule,
          ))
        ],
      ),
    );
  }
}

class NextBusModel {
  final bool isFromIITH;
  final String time;
  final String timeDifference;
  final bool isEv;
  final int diff;

  NextBusModel(
      {required this.isFromIITH,
      required this.isEv,
      required this.time,
      required this.diff,
      required this.timeDifference});
}

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({super.key, required this.busSchedule});
  final BusSchedule busSchedule;

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  bool fullSchedule = false;
  String defaultShow = 'Maingate';
  List fromLingam = ["22:00"];
  List toLingam = ["10:00"];
  late bool isLoading = true;

  List noBuses = ["00:00"];
  final List<bool> selectedOption = [true, false];
  final List<Widget> weekdayOrWeekend = [
    Text(
      'Weekday',
      style: GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    ),
    Text(
      'Weekend',
      style: GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    )
  ];

  final List<Widget> fullScheduleWidget = [
    Text(
      'Upcoming',
      style: GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    Text(
      'Full Schedule',
      style: GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    )
  ];

  List<NextBusModel> getNextTwoBusesFromMaingate() {
    if (widget.busSchedule == null) return [];
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
            time = time.add(Duration(days: 1));
          }

          return MapEntry(time, entry.value);
        })
        .where((entry) => entry.key.isAfter(now))
        .toList();

    busTimes.sort((a, b) => a.key.compareTo(b.key));

    return busTimes.take(2).map((entry) {
      Duration difference = entry.key.difference(
          DateTime(now.year, now.month, now.day, now.hour, now.minute));
      int minutes = difference.inMinutes;
      String formattedDifference = "$minutes minutes";

      return NextBusModel(
          diff: minutes,
          isFromIITH: false,
          isEv: entry.value == 1,
          time:
              "${entry.key.hour.toString().padLeft(2, '0')}:${entry.key.minute.toString().padLeft(2, '0')}",
          timeDifference: formattedDifference);
    }).toList();
  }

  List<NextBusModel> getNextTwoBusesFromHostelCircle() {
    if (widget.busSchedule == null) return [];
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
            time = time.add(Duration(days: 1));
          }

          return MapEntry(time, entry.value);
        })
        .where((entry) => entry.key.isAfter(now))
        .toList();

    busTimes.sort((a, b) => a.key.compareTo(b.key));

    return busTimes.take(2).map((entry) {
      Duration difference = entry.key.difference(
          DateTime(now.year, now.month, now.day, now.hour, now.minute));
      int minutes = difference.inMinutes;
      String formattedDifference = "$minutes minutes";

      return NextBusModel(
        diff: minutes,
        isFromIITH: true,
        isEv: entry.value == 1,
        time:
            "${entry.key.hour.toString().padLeft(2, '0')}:${entry.key.minute.toString().padLeft(2, '0')}",
        timeDifference: formattedDifference,
      );
    }).toList();
  }

  List<NextBusModel> getNextBuses() {
    List<NextBusModel> maingateBuses = getNextTwoBusesFromMaingate();
    List<NextBusModel> hostelCircleBuses = getNextTwoBusesFromHostelCircle();

    List<NextBusModel> combinedBuses = [];
    combinedBuses.addAll(maingateBuses);
    combinedBuses.addAll(hostelCircleBuses);

    combinedBuses.sort((a, b) => a.diff.compareTo(b.diff));

    return combinedBuses;
  }

  List<NextBusModel>? nextBuses;
  Timer? _timer;

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

  void updateNextBuses() {
    setState(() {
      nextBuses = getNextBuses();
    });
  }

  final analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    updateNextBuses();
    setInitialTimer();
    analyticsService.logScreenView(screenName: "Bus Schedule Screen");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget justSomeRandomShit() {
    return Text(
      '* indicates EV',
      style: GoogleFonts.inter(
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 6,
        ),
        ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (index) {
            setState(() {
              if (index == 1) {
                fullSchedule = true;
              } else {
                fullSchedule = false;
              }
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
          fillColor: const Color.fromRGBO(254, 114, 76, 0.70),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 150.0,
          ),
          isSelected: [!fullSchedule, fullSchedule],
          children: fullScheduleWidget,
        ),
        !fullSchedule
            ? Expanded(
                child: nextBuses == null || nextBuses?.length == 0
                    ? ListView(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No upcoming buses available",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ])
                    : ListView.builder(
                        itemCount: nextBuses?.length ?? 0,
                        itemBuilder: (context, index) {
                          final bus = nextBuses![index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: NextBusCard(
                              from:
                                  bus.isFromIITH ? 'Hostel Circle' : 'Maingate',
                              destination:
                                  bus.isFromIITH ? 'Maingate' : 'Hostel Circle',
                              waitingTime: bus.timeDifference,
                              isEv: bus.isEv,
                            ),
                          );
                        },
                      ),
              )
            : Expanded(
                child: Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Padding(
                    //       padding:
                    //           const EdgeInsets.fromLTRB(24, 10, 0, 0),
                    //       child: DropdownButton<String>(
                    //         underline: Container(),
                    //         value: defaultShow,
                    //         items: <String>[
                    //           'Maingate',
                    //           'Lingampally',
                    //           'Sangareddy'
                    //         ].map<DropdownMenuItem<String>>(
                    //             (String value) {
                    //           return DropdownMenuItem<String>(
                    //             value: value,
                    //             child: Text(
                    //               value,
                    //               style: GoogleFonts.inter(
                    //                 fontSize: 15.0,
                    //                 fontWeight: FontWeight.w600,
                    //                 letterSpacing: -0.2,
                    //               ),
                    //             ),
                    //           );
                    //         }).toList(),
                    //         onChanged: (String? value) {
                    //           setState(() {
                    //             defaultShow = value!;
                    //           });
                    //         },
                    //         focusColor: Colors.white,
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    //       child: ToggleButtons(
                    //         direction: Axis.horizontal,
                    //         onPressed: (index) {
                    //           setState(() {
                    //             for (var i = 0;
                    //                 i < selectedOption.length;
                    //                 i++) {
                    //               selectedOption[i] = i == index;
                    //             }
                    //           });
                    //         },
                    //         borderRadius: const BorderRadius.all(
                    //             Radius.circular(7.0)),
                    //         fillColor:
                    //             const Color.fromARGB(255, 198, 198, 198),
                    //         constraints: const BoxConstraints(
                    //           minHeight: 24.0,
                    //           minWidth: 85.0,
                    //         ),
                    //         isSelected: selectedOption,
                    //         children: weekdayOrWeekend,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // defaultShow == 'Maingate'?

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 6.0, bottom: 6.0),
                              child: BusTimingList(
                                  from: 'Maingate',
                                  destination: 'Hostel',
                                  timings: widget.busSchedule.fromIITH), //TODO
                            )),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 6.0, bottom: 6.0),
                              child: BusTimingList(
                                  from: 'Hostel',
                                  destination: 'Maingate',
                                  timings: widget.busSchedule.toIITH), //TODO
                            ))
                          ],
                        ),
                      ),
                    ),
                    justSomeRandomShit()
                    // : defaultShow == 'Lingampally'
                    //     ? selectedOption[1]
                    //         ? Expanded(
                    //             child: Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 Expanded(
                    //                     child: Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 6.0, bottom: 6.0),
                    //                   child: BusTimingList(
                    //                       from: 'IITH',
                    //                       destinantion: 'Lingampally',
                    //                       timings: busSchedule
                    //                                   .fromIITH[
                    //                               "LINGAMPALLYW"] ??
                    //                           noBuses),
                    //                 )),
                    //                 const SizedBox(
                    //                   width: 4.0,
                    //                 ),
                    //                 Expanded(
                    //                     child: Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       right: 6.0, bottom: 6.0),
                    //                   child: BusTimingList(
                    //                       from: 'Lingampally',
                    //                       destinantion: 'IITH',
                    //                       timings: busSchedule.toIITH[
                    //                               "LINGAMPALLYW"] ??
                    //                           noBuses),
                    //                 ))
                    //               ],
                    //             ),
                    //           )
                    //         : Expanded(
                    //             child: Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 Expanded(
                    //                     child: Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 6.0, bottom: 12.0),
                    //                   child: BusTimingList(
                    //                       from: 'IITH',
                    //                       destinantion: 'Lingampally',
                    //                       timings: busSchedule
                    //                                   .fromIITH[
                    //                               "LINGAMPALLY"] ??
                    //                           noBuses),
                    //                 )),
                    //                 const SizedBox(
                    //                   width: 4.0,
                    //                 ),
                    //                 Expanded(
                    //                     child: Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       right: 6.0, bottom: 12.0),
                    //                   child: BusTimingList(
                    //                       from: 'Lingampally',
                    //                       destinantion: 'IITH',
                    //                       timings: busSchedule.toIITH[
                    //                               "LINGAMPALLY"] ??
                    //                           noBuses),
                    //                 ))
                    //               ],
                    //             ),
                    //           )
                    //     : defaultShow == 'Sangareddy'
                    //         ? selectedOption[1]
                    //             ? Expanded(
                    //                 child: Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment
                    //                           .spaceBetween,
                    //                   children: [
                    //                     Expanded(
                    //                         child: Padding(
                    //                       padding:
                    //                           const EdgeInsets.only(
                    //                               left: 6.0,
                    //                               bottom: 6.0),
                    //                       child: BusTimingList(
                    //                           from: 'IITH',
                    //                           destinantion:
                    //                               'Sangareddy',
                    //                           timings: busSchedule
                    //                                       .fromIITH[
                    //                                   "SANGAREDDYW"] ??
                    //                               noBuses),
                    //                     )),
                    //                     const SizedBox(
                    //                       width: 4.0,
                    //                     ),
                    //                     Expanded(
                    //                         child: Padding(
                    //                       padding:
                    //                           const EdgeInsets.only(
                    //                               right: 6.0,
                    //                               bottom: 6.0),
                    //                       child: BusTimingList(
                    //                           from: 'Sangareddy',
                    //                           destinantion: 'IITH',
                    //                           timings: busSchedule
                    //                                       .toIITH[
                    //                                   "SANGAREDDYW"] ??
                    //                               noBuses),
                    //                     ))
                    //                   ],
                    //                 ),
                    //               )
                    //             : Expanded(
                    //                 child: Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment
                    //                           .spaceBetween,
                    //                   children: [
                    //                     Expanded(
                    //                         child: Padding(
                    //                       padding:
                    //                           const EdgeInsets.only(
                    //                               left: 6.0,
                    //                               bottom: 12.0),
                    //                       child: BusTimingList(
                    //                           from: 'IITH',
                    //                           destinantion:
                    //                               'Sangareddy',
                    //                           timings: busSchedule
                    //                                       .fromIITH[
                    //                                   "SANGAREDDY"] ??
                    //                               noBuses),
                    //                     )),
                    //                     const SizedBox(
                    //                       width: 4.0,
                    //                     ),
                    //                     Expanded(
                    //                         child: Padding(
                    //                       padding:
                    //                           const EdgeInsets.only(
                    //                               right: 6.0,
                    //                               bottom: 12.0),
                    //                       child: BusTimingList(
                    //                           from: 'Sangareddy',
                    //                           destinantion: 'IITH',
                    //                           timings: busSchedule
                    //                                       .toIITH[
                    //                                   "SANGAREDDY"] ??
                    //                               noBuses),
                    //                     ))
                    //                   ],
                    //                 ),
                    //               )
                    //         : Container()
                  ],
                ),
              )
      ],
    );
  }
}

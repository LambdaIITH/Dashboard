import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/bus_schedule.dart';
import 'package:frontend/utils/loading_widget.dart';
import 'package:frontend/widgets/bus_timing_list_widget.dart';
import 'package:frontend/widgets/next_bus_card_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class BusTimingsScreen extends StatefulWidget {
  const BusTimingsScreen({super.key});

  @override
  State<BusTimingsScreen> createState() => _BusTimingsScreenState();
}

class _BusTimingsScreenState extends State<BusTimingsScreen> {
  late Future<BusSchedule> busSchedule;

  @override
  void initState() {
    super.initState();
    busSchedule = loadBusSchedule();
  }

  Future<BusSchedule> loadBusSchedule() async {
    String jsonString = await rootBundle.loadString('assets/bus.json');
    final jsonResponse = json.decode(jsonString);
    return BusSchedule.fromJson(jsonResponse);
  }

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
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ Expanded(child: BusSchedulePage())],
      ),
    );
  }
}

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({super.key});

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  bool fullSchedule = false;
  String defaultShow = 'Maingate';
  List fromLingam = ["22:00"];
  List toLingam = ["10:00"];
  late BusSchedule busSchedule;
  bool isLoading = true;

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
      'Next Buses',
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

  @override
  void initState() {
    super.initState();
    loadBusSchedule();
  }

  Future<void> loadBusSchedule() async {
    String jsonString = await rootBundle.loadString('assets/bus.json');
    final jsonResponse = json.decode(jsonString);
    setState(() {
      busSchedule = BusSchedule.fromJson(jsonResponse);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CustomLoadingScreen()
        : Column(
            children: [
              const SizedBox(height: 6,),
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
                  ? const Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: NextBusCard(
                                  from: 'Main Gate',
                                  destinantion: 'Hostel Circle',
                                  waitingTime: '10 Minutes'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: NextBusCard(
                                  from: 'Hostel Circle',
                                  destinantion: 'Main Gate',
                                  waitingTime: '13 Minutes'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: NextBusCard(
                                  from: 'New Hostel',
                                  destinantion: 'Hostel Circle',
                                  waitingTime: '9 Minutes'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: NextBusCard(
                                  from: 'Hostel Circle',
                                  destinantion: 'New Hostel',
                                  waitingTime: '15 Minutes'),
                            ),
                            SizedBox(
                              height: 10.0,
                            )
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 10, 0, 0),
                                child: DropdownButton<String>(
                                  underline: Container(),
                                  value: defaultShow,
                                  items: <String>[
                                    'Maingate',
                                    'Lingampally',
                                    'Sangareddy'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: GoogleFonts.inter(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      defaultShow = value!;
                                    });
                                  },
                                  focusColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                child: ToggleButtons(
                                  direction: Axis.horizontal,
                                  onPressed: (index) {
                                    setState(() {
                                      for (var i = 0;
                                          i < selectedOption.length;
                                          i++) {
                                        selectedOption[i] = i == index;
                                      }
                                    });
                                  },
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(7.0)),
                                  fillColor:
                                      const Color.fromARGB(255, 198, 198, 198),
                                  constraints: const BoxConstraints(
                                    minHeight: 24.0,
                                    minWidth: 85.0,
                                  ),
                                  isSelected: selectedOption,
                                  children: weekdayOrWeekend,
                                ),
                              )
                            ],
                          ),
                          defaultShow == 'Maingate'
                              ? Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6.0, bottom: 6.0),
                                        child: BusTimingList(
                                            from: 'Maingate',
                                            destinantion: 'Hostel',
                                            timings:
                                                busSchedule.toIITH["LAB"] ??
                                                    noBuses),
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
                                            destinantion: 'Maingate',
                                            timings:
                                                busSchedule.fromIITH["LAB"] ??
                                                    noBuses),
                                      ))
                                    ],
                                  ),
                                )
                              : defaultShow == 'Lingampally'
                                  ? selectedOption[1]
                                      ? Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6.0, bottom: 6.0),
                                                child: BusTimingList(
                                                    from: 'IITH',
                                                    destinantion: 'Lingampally',
                                                    timings: busSchedule
                                                                .fromIITH[
                                                            "LINGAMPALLYW"] ??
                                                        noBuses),
                                              )),
                                              const SizedBox(
                                                width: 4.0,
                                              ),
                                              Expanded(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 6.0, bottom: 6.0),
                                                child: BusTimingList(
                                                    from: 'Lingampally',
                                                    destinantion: 'IITH',
                                                    timings: busSchedule.toIITH[
                                                            "LINGAMPALLYW"] ??
                                                        noBuses),
                                              ))
                                            ],
                                          ),
                                        )
                                      : Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6.0, bottom: 12.0),
                                                child: BusTimingList(
                                                    from: 'IITH',
                                                    destinantion: 'Lingampally',
                                                    timings: busSchedule
                                                                .fromIITH[
                                                            "LINGAMPALLY"] ??
                                                        noBuses),
                                              )),
                                              const SizedBox(
                                                width: 4.0,
                                              ),
                                              Expanded(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 6.0, bottom: 12.0),
                                                child: BusTimingList(
                                                    from: 'Lingampally',
                                                    destinantion: 'IITH',
                                                    timings: busSchedule.toIITH[
                                                            "LINGAMPALLY"] ??
                                                        noBuses),
                                              ))
                                            ],
                                          ),
                                        )
                                  : defaultShow == 'Sangareddy'
                                      ? selectedOption[1]
                                          ? Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6.0,
                                                            bottom: 6.0),
                                                    child: BusTimingList(
                                                        from: 'IITH',
                                                        destinantion:
                                                            'Sangareddy',
                                                        timings: busSchedule
                                                                    .fromIITH[
                                                                "SANGAREDDYW"] ??
                                                            noBuses),
                                                  )),
                                                  const SizedBox(
                                                    width: 4.0,
                                                  ),
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 6.0,
                                                            bottom: 6.0),
                                                    child: BusTimingList(
                                                        from: 'Sangareddy',
                                                        destinantion: 'IITH',
                                                        timings: busSchedule
                                                                    .toIITH[
                                                                "SANGAREDDYW"] ??
                                                            noBuses),
                                                  ))
                                                ],
                                              ),
                                            )
                                          : Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6.0,
                                                            bottom: 12.0),
                                                    child: BusTimingList(
                                                        from: 'IITH',
                                                        destinantion:
                                                            'Sangareddy',
                                                        timings: busSchedule
                                                                    .fromIITH[
                                                                "SANGAREDDY"] ??
                                                            noBuses),
                                                  )),
                                                  const SizedBox(
                                                    width: 4.0,
                                                  ),
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 6.0,
                                                            bottom: 12.0),
                                                    child: BusTimingList(
                                                        from: 'Sangareddy',
                                                        destinantion: 'IITH',
                                                        timings: busSchedule
                                                                    .toIITH[
                                                                "SANGAREDDY"] ??
                                                            noBuses),
                                                  ))
                                                ],
                                              ),
                                            )
                                      : Container()
                        ],
                      ),
                    )
            ],
          );
  }
}

import 'dart:async';

import 'package:dashbaord/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/screens/cab_add_screen.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/cab_details.dart';
import 'package:dashbaord/widgets/cab_search_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/models/booking_model.dart';

class CabSharingScreen extends StatefulWidget {
  final UserModel user;
  final String image;
  final bool isMyRide;
  const CabSharingScreen(
      {Key? key,
      required this.user,
      required this.image,
      this.isMyRide = false})
      : super(key: key);
  @override
  State<CabSharingScreen> createState() => _CabSharingScreenState();
}

class _CabSharingScreenState extends State<CabSharingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedOption;
  String? selectedOption2;
  DateTime? startTime;
  DateTime? endTime;
  bool isTabOneSelected = true;
  final analyticsService = FirebaseAnalyticsService();
  bool isLoading = true;
  int state = 0;

  bool sortBySeatsSelected = false;
  bool sortBySeatsDescendingSelected = false;
  bool sortByEndTimeSelected = false;
  bool sortByEndTimeDescendingSelected = false;

  changeLoadingState() {
    state++;
    if (state >= 2) {
      isLoading = false;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isTabOneSelected = !widget.isMyRide;
    analyticsService.logScreenView(screenName: "Cab Share Screen");
    getAllCabs();
    getUserCabs();
  }

  final List<Widget> tabNames = [
    Text(
      'All Rides',
      style: GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    Text(
      'My Rides',
      style: GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  ];

  void updateSearchForm({
    DateTime? start,
    DateTime? end,
    String? searchSelectedOption,
    String? searchSelectedOption2,
  }) {
    setState(() {
      selectedOption = searchSelectedOption;
      selectedOption2 = searchSelectedOption2;
      startTime = start;
      endTime = end;
    });
    searchCabs(start, end, searchSelectedOption, searchSelectedOption2);
  }

  // From the API service
  ApiServices apiServices = ApiServices();

  List<BookingModel> allBookings = [];
  List<BookingModel> allBookingsSTORED = [];
  getAllCabs() async {
    final cabs = await apiServices.getBookings(context);
    if (cabs.isEmpty && allBookingsSTORED.isNotEmpty) {
      return;
    }
    setState(() {
      allBookings = cabs;
      allBookingsSTORED = [...cabs];
      sortBySeatsSelected = false;
      sortBySeatsDescendingSelected = false;
      sortByEndTimeDescendingSelected = false;
      sortByEndTimeSelected = false;
    });
    changeLoadingState();
  }

  searchCabs(DateTime? startTime, DateTime? endTime,
      String? searchSelectedOption, String? searchSelectedOption2) async {
    final cabs = await apiServices.getBookings(context,
        fromLoc: selectedOption,
        toLoc: selectedOption2,
        startTime: startTime?.toIso8601String(),
        endTime: endTime?.toIso8601String());
    setState(() {
      allBookings = cabs;
    });
  }

  List<BookingModel> userBookings = [];
  getUserCabs() async {
    final cabs = await apiServices.getUserBookings(context);
    setState(() {
      userBookings = cabs;
    });
    changeLoadingState();
  }

  openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Rides',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: CabSearch(
              onSearch: updateSearchForm,
              startDate: startTime,
              endDate: endTime,
              from: selectedOption,
              to: selectedOption2,
            ),
          ),
        );
      },
    );
  }

  void sortBySeats() {
    setState(() {
      sortBySeatsSelected = !sortBySeatsSelected;
      if (sortBySeatsSelected) {
        sortBySeatsDescendingSelected = false;
        sortByEndTimeDescendingSelected = false;
        sortByEndTimeSelected = false;
        allBookings.sort((a, b) => (a.capacity - a.travellers.length)
            .compareTo(b.capacity - b.travellers.length));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  void sortBySeatsDescending() {
    setState(() {
      sortBySeatsDescendingSelected = !sortBySeatsDescendingSelected;
      if (sortBySeatsDescendingSelected) {
        sortBySeatsSelected = false;
        sortByEndTimeDescendingSelected = false;
        sortByEndTimeSelected = false;
        allBookings.sort((a, b) => (b.capacity - b.travellers.length)
            .compareTo(a.capacity - a.travellers.length));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  void sortByEndTime() {
    setState(() {
      sortByEndTimeSelected = !sortByEndTimeSelected;
      if (sortByEndTimeSelected) {
        sortByEndTimeDescendingSelected = false;
        sortBySeatsSelected = false;
        sortBySeatsDescendingSelected = false;
        allBookings.sort((a, b) => a.endTime.compareTo(b.endTime));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  void sortByEndTimeDescending() {
    setState(() {
      sortByEndTimeDescendingSelected = !sortByEndTimeDescendingSelected;
      if (sortByEndTimeDescendingSelected) {
        sortByEndTimeSelected = false;
        sortBySeatsSelected = false;
        sortBySeatsDescendingSelected = false;
        allBookings.sort((a, b) => b.endTime.compareTo(a.endTime));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget allRides = RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
          () {
            getAllCabs();
          },
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<int>(
                  icon: const Icon(
                    Icons.sort_outlined,
                    size: 30.0,
                    color: Color(0xffFE724C),
                  ),
                  onSelected: (value) {
                    if (value == 1) {
                      sortBySeats();
                    } else if (value == 2) {
                      sortBySeatsDescending();
                    } else if (value == 3) {
                      sortByEndTime();
                    } else if (value == 4) {
                      sortByEndTimeDescending();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortBySeatsSelected,
                            onChanged: (value) {
                              sortBySeats();
                              Navigator.pop(context);
                            },
                          ),
                          const Text('Sort by Seats'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortBySeatsDescendingSelected,
                            onChanged: (value) {
                              sortBySeatsDescending();
                              Navigator.pop(context);
                            },
                          ),
                          const Text('Sort by Seats Desc'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortByEndTimeSelected,
                            onChanged: (value) {
                              sortByEndTime();
                              Navigator.pop(context);
                            },
                          ),
                          const Text('Sort by End Time'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 4,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortByEndTimeDescendingSelected,
                            onChanged: (value) {
                              sortByEndTimeDescending();
                              Navigator.pop(context);
                            },
                          ),
                          const Text('Sort by End Time Desc'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: openFilterDialog,
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    size: 30.0,
                    color: Color(0xffFE724C),
                  ),
                ),
              ],
            ),
          ),
          allBookings.isEmpty
              ? Expanded(
                  child: ListView(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          'No rides found',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: allBookings.length,
                    itemBuilder: (ctx, inx) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: allBookings[inx].capacity !=
                              allBookings[inx].travellers.length
                          ? CabCard(
                              onRefresh: () {
                                return Future.delayed(
                                  const Duration(seconds: 1),
                                  () {
                                    getAllCabs();
                                  },
                                );
                              },
                              cab: allBookings[inx],
                              user: widget.user,
                            )
                          : null,
                    ),
                  ),
                ),
        ],
      ),
    );

    Widget myRides = RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
          () {
            getUserCabs();
          },
        );
      },
      child: Column(
        children: [
          // TODO : Add both past and future rides
          userBookings.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: userBookings.length,
                    itemBuilder: (ctx, inx) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CabCard(
                        onRefresh: () {
                          return Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              getUserCabs();
                            },
                          );
                        },
                        cab: userBookings[inx],
                        user: widget.user,
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        child: Text(
                          'You have no rides',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Cab Sharing',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
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
      floatingActionButton: isTabOneSelected
          ? Container()
          : FloatingActionButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CabAddScreen(
                      user: widget.user,
                      image: widget.image,
                    ),
                  ),
                );
              },
              backgroundColor: const Color.fromARGB(204, 254, 115, 76),
              child: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
      body: isLoading
          ? const CustomLoadingScreen()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                        offset: Offset(0, 4), // Offset in the x, y direction
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ]),
                    child: ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (index) {
                        setState(() {
                          isTabOneSelected = index == 0;
                        });
                      },
                      borderRadius:
                          const BorderRadius.all(Radius.circular(7.0)),
                      fillColor: const Color.fromRGBO(254, 114, 76, 0.70),
                      constraints: const BoxConstraints(
                        minHeight: 44.0,
                        minWidth: 130.0,
                      ),
                      isSelected: [isTabOneSelected, !isTabOneSelected],
                      children: tabNames,
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Expanded(child: isTabOneSelected ? allRides : myRides),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/models/booking_model.dart';
import 'package:frontend/models/travellers.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/cab_add_success.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/services/api_service.dart';
import 'package:intl/intl.dart';

class CabAddScreen extends StatefulWidget {
  final String usersEmail;
  const CabAddScreen({Key? key, required this.usersEmail}) : super(key: key);
  @override
  State<CabAddScreen> createState() => _CabAddScreenState();
}

class _CabAddScreenState extends State<CabAddScreen> {
  // DateTime? selectedDate;
  // String? selectedFromPlace;
  // String? selectedToPlace;
  String? selectedLocation;
  // TimeOfDay? selectedStartTime;
  // TimeOfDay? selectedEndTime;

  DateTime? selectedStartDateTime;
  DateTime? selectedEndDateTime;
  String? seats;
  bool isFrom = true;
  TextEditingController commentController = TextEditingController();

  List<String> locations = [
    // 'IITH',
    'RGIA',
    'Secun. Railway Stn.',
    "Lingampally Stn.",
    "Kacheguda Stn.",
    "Hyd. Deccan Stn."
  ];

  @override
  void initState() {
    super.initState();
    getUserDetails();
    commentController.addListener(updateButtonStatus);
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  Future<void> _selectDateTime(BuildContext context,
      {required bool isStart}) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = selectedStartDateTime ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStart ? now : selectedStartDateTime ?? now,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay initialTime = isStart
          ? const TimeOfDay(hour: 12, minute: 0)
          : TimeOfDay.fromDateTime(initialDate.add(const Duration(hours: 1)));
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            if (pickedDateTime.isBefore(now)) {
              selectedStartDateTime = now;
            } else {
              selectedStartDateTime = pickedDateTime;
            }
            if (selectedEndDateTime != null &&
                selectedEndDateTime!.isBefore(pickedDateTime)) {
              selectedEndDateTime =
                  pickedDateTime.add(const Duration(hours: 1));
            }

            if (selectedEndDateTime != null &&
                selectedEndDateTime!.difference(pickedDateTime).inHours.abs() >=
                    24) {
              //TODO: show a taost
              selectedStartDateTime = null;
            }
          } else {
            if (pickedDateTime.isBefore(now)) {
              selectedEndDateTime = now;
            } else if (selectedStartDateTime != null &&
                pickedDateTime.isBefore(selectedStartDateTime!)) {
              selectedEndDateTime =
                  selectedStartDateTime!.add(const Duration(hours: 1));
            } else {
              selectedEndDateTime = pickedDateTime;
            }

            if (selectedStartDateTime != null &&
                selectedStartDateTime!
                        .difference(pickedDateTime)
                        .inHours
                        .abs() >=
                    24) {
              //TODO: show a taost
              selectedEndDateTime = null;
            }
          }
          updateButtonStatus();
        });
      }
    }
  }

  // API Service
  ApiServices apiServices = ApiServices();

  UserModel? userDetails;
  void getUserDetails() async {
    final user = await apiServices.getUserDetails(context);
    userDetails = user;
  }

  bool updateButtonStatus() {
    setState(() {});
    return selectedEndDateTime != null &&
        selectedStartDateTime != null &&
        seats != null &&
        selectedLocation != null &&
        commentController.text.trim().isNotEmpty;
  }

  void createCab() async {
    // Check for phone number
    if (userDetails?.phone == null || userDetails?.phone == '') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Phone Number not addded'),
          content: const Text(
            'Please update your phone number in the profile section before adding a cab.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
      return;
    }
    if (selectedEndDateTime == null ||
        selectedStartDateTime == null ||
        seats == null ||
        selectedLocation == null ||
        userDetails == null ||
        // userDetails?.phone == null ||//TODO: implement this
        commentController.text.trim().isEmpty) {
      return;
    }
    final BookingModel bookingModel = BookingModel(
      id: 0,
      startTime: selectedStartDateTime!,
      endTime: selectedEndDateTime!,
      capacity: int.parse(seats!),
      fromLoc: isFrom ? 'IITH' : selectedLocation!,
      toLoc: isFrom ? selectedLocation! : 'IITH',
      ownerEmail: userDetails!.email,
      travellers: [
        TravellersModel(
          name: userDetails!.name,
          email: userDetails!.email,
          phoneNumber: userDetails!.phone ?? '',
          comments: commentController.text.trim(),
        ),
      ],
      requests: [],
    );
    try {
      final res = await apiServices.createBooking(bookingModel);
      if (!mounted) return;
      if (res["error"] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CabAddSuccess(usersEmail: widget.usersEmail)),
        );
      } else {
        showErrorDialog(context, res["error"]);
      }
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xffFCFCFC),
        title: Text('Add a Cab',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 22.0,
          vertical: 16.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                        // Shadow color
                        offset: Offset(0, 8), // Offset in the x, y direction
                        blurRadius: 21.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        'IITH',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                // Expanded(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(10.0),
                //       boxShadow: const [
                //         BoxShadow(
                //           color:
                //               Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                //           offset: Offset(0, 4), // Offset in the x, y direction
                //           blurRadius: 10.0,
                //           spreadRadius: 0.0,
                //         ),
                //       ],
                //     ),
                //     child: DropdownButtonFormField<String>(
                //       borderRadius: BorderRadius.circular(10.0),
                //       decoration: const InputDecoration(
                //         border: InputBorder.none,
                //         contentPadding: EdgeInsets.symmetric(
                //           horizontal: 15.0,
                //           vertical: 25.0,
                //         ),
                //       ),
                //       items: locations.map((String location) {
                //         String displayText = location.length > 7
                //             ? '${location.substring(0, 7)}..'
                //             : location;
                //         return DropdownMenuItem<String>(
                //           value: location,
                //           child: Text(
                //             displayText,
                //             style: GoogleFonts.inter(
                //               fontSize: 17,
                //               fontWeight: FontWeight.w500,
                //               color: Colors.black,
                //             ),
                //           ),
                //         );
                //       }).toList(),
                //       onChanged: (String? value) {
                //         selectedFromPlace = value;
                //       },
                //       hint: selectedFromPlace == null
                //           ? Text(
                //               'From',
                //               style: GoogleFonts.inter(
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.w600,
                //                 color: const Color(0xffADADAD),
                //               ),
                //             )
                //           : null,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        isFrom = !isFrom;
                        updateButtonStatus();
                      });
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromRGBO(254, 114, 76, 0.70),
                        ),
                        child: Icon(
                          isFrom ? Icons.arrow_forward : Icons.arrow_back,
                          size: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                          // Shadow color
                          offset: Offset(0, 8), // Offset in the x, y direction
                          blurRadius: 21.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      borderRadius: BorderRadius.circular(10.0),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 0.0,
                        ),
                      ),
                      items: locations.map((String location) {
                        String displayText = location;
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(
                            displayText,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          if (value != null) {
                            selectedLocation = value;
                            updateButtonStatus();
                          }
                        });
                      },
                      hint: selectedLocation == null
                          ? Text(
                              'Location',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xffADADAD),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            _dateTimePicker('Start Time', selectedStartDateTime, true),
            const SizedBox(height: 12.0),
            _dateTimePicker('End Time', selectedEndDateTime, false),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                    offset: Offset(0, 8), // Offset in the x, y direction
                    blurRadius: 21.0,
                    spreadRadius: 0.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(10.0),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 12, 0),
                  ),
                  items: ['1', '2', '3', '4', '5', '6'].map((String seat) {
                    return DropdownMenuItem<String>(
                      value: seat,
                      child: Text(
                        seat,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) {
                        updateButtonStatus();
                        seats = value;
                      }
                    });
                  },
                  hint: Text(
                    'Seats including yours',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffADADAD),
                    ),
                  )),
            ),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                    offset: Offset(0, 8), // Offset in the x, y direction
                    blurRadius: 21.0,
                    spreadRadius: 0.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: TextFormField(
                maxLines: 4,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                controller: commentController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Comments',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xffADADAD),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: TextButton(
                  // style: ElevatedButton.styleFrom(
                  //   primary: const Color.fromRGBO(254, 114, 76, 0.70),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10.0),
                  //   ),
                  // ),
                  onPressed: !updateButtonStatus()
                      ? null
                      : () {
                          createCab();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: !updateButtonStatus()
                          ? Colors.grey
                          : const Color.fromRGBO(254, 114, 76, 0.70),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                          offset: Offset(0, 8), // Offset in the x, y direction
                          blurRadius: 21.0,
                          spreadRadius: 4.0,
                        ),
                      ],
                    ),
                    // color: const Color.fromRGBO(254, 114, 76, 0.70),
                    width: double.infinity,
                    height: 60,
                    alignment: Alignment.center,
                    child: Text(
                      'Add Cab',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
          ],
        ),
      ),
    );
  }

  Widget _dateTimePicker(String label, DateTime? dateTime, bool isStart) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(51, 51, 51, 0.10),
            offset: Offset(0, 8),
            blurRadius: 21.0,
            spreadRadius: 0.0,
          ),
        ],
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        readOnly: true,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          suffixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xffADADAD),
          ),
          hintText: label,
          hintStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xffADADAD),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
        ),
        onTap: () => _selectDateTime(context, isStart: isStart),
        controller: TextEditingController(
          text: dateTime == null
              ? ''
              : "${DateFormat('yyyy-MM-dd – kk:mm').format(dateTime)}",
        ),
      ),
    );
  }
}

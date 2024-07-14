import 'package:flutter/material.dart';
import 'package:frontend/models/booking_model.dart';
import 'package:frontend/models/travellers.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/cab_add_success.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/services/api_service.dart';

class CabAddScreen extends StatefulWidget {
  const CabAddScreen({Key? key}) : super(key: key);
  @override
  State<CabAddScreen> createState() => _CabAddScreenState();
}

class _CabAddScreenState extends State<CabAddScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedFromPlace;
  String? selectedToPlace;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String? seats;

  List<String> locations = [
    'IITH',
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
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
      });
    }
  }

  // API Service
  ApiServices apiServices = ApiServices();

  UserModel? userDetails;
  void getUserDetails() async {
    final user = await apiServices.getUserDetails(context);
    userDetails = user;
  }

  void createCab() async {
    if (selectedStartTime == null ||
        selectedEndTime == null ||
        seats == null ||
        selectedFromPlace == null ||
        selectedToPlace == null ||
        userDetails == null) {
      return;
    }
    final BookingModel bookingModel = BookingModel(
      id: 0,
      startTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedStartTime!.hour,
        selectedStartTime!.minute,
      ),
      endTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedEndTime!.hour,
        selectedEndTime!.minute,
      ),
      capacity: int.parse(seats!),
      fromLoc: selectedFromPlace!,
      toLoc: selectedToPlace!,
      ownerEmail: userDetails!.email,
      travellers: [
        TravellersModel(
          name: userDetails!.name,
          email: userDetails!.email,
          phoneNumber: userDetails!.phone ?? '',
          comments: 'From the test APP',
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
          MaterialPageRoute(builder: (context) => const CabAddSuccess()),
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                          offset: Offset(0, 4), // Offset in the x, y direction
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      borderRadius: BorderRadius.circular(10.0),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 25.0,
                        ),
                      ),
                      items: locations.map((String location) {
                        String displayText = location.length > 7
                            ? '${location.substring(0, 7)}..'
                            : location;
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
                        selectedFromPlace = value;
                      },
                      hint: selectedFromPlace == null
                          ? Text(
                              'From',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffADADAD),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.arrow_forward,
                      size: 25.0, color: Color(0xffADADAD)),
                ),
                Expanded(
                  child: Container(
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
                          horizontal: 15.0,
                          vertical: 25.0,
                        ),
                      ),
                      items: locations.map((String location) {
                        String displayText = location.length > 7
                            ? '${location.substring(0, 7)}..'
                            : location;
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
                        selectedToPlace = value;
                      },
                      hint: selectedToPlace == null
                          ? Text(
                              'To',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffADADAD),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
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
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      readOnly: true,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.date_range,
                          color: Color(0xffADADAD),
                        ),
                        hintText: selectedFromPlace == null
                            ? 'Date'
                            : "${selectedDate.toLocal()}".split(' ')[0],
                        hintStyle: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffADADAD),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ),
                      ),
                      onTap: () => _selectDate(context),
                      controller: TextEditingController(
                        text: "${selectedDate.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
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
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      readOnly: true,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.access_time,
                          color: Color(0xffADADAD),
                        ),
                        hintText: 'Start Time',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffADADAD),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ),
                      ),
                      onTap: () => _selectStartTime(context),
                      controller: TextEditingController(
                        text: selectedStartTime == null
                            ? 'Start Time'
                            : "${selectedStartTime?.hour}:${selectedStartTime?.minute} ",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
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
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      readOnly: true,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.access_time,
                          color: Color(0xffADADAD),
                        ),
                        hintText: 'End Time',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffADADAD),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ),
                      ),
                      onTap: () => _selectEndTime(context),
                      controller: TextEditingController(
                        text: selectedEndTime == null
                            ? 'End Time'
                            : "${selectedEndTime?.hour}:${selectedEndTime?.minute}",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25.0),
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 25.0,
                  ),
                ),
                items: [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                ].map((String seat) {
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
                  seats = value;
                },
                hint: seats == null
                    ? Text(
                        'Seats',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffADADAD),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 25.0),
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
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const CabAddSuccess(),
                    //   ),
                    // );
                    createCab();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color.fromRGBO(254, 114, 76, 0.70),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                          offset: Offset(0, 8), // Offset in the x, y direction
                          blurRadius: 21.0,
                          spreadRadius: 0.0,
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
}

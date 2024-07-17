import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:intl/intl.dart";
import 'package:frontend/models/booking_model.dart';

class CabCard extends StatefulWidget {
  final bool isExpanded;
  final BookingModel cab;
  final String usersEmail;
  final Function onRefresh;

  const CabCard(
      {super.key,
      this.isExpanded = false,
      required this.cab,
      required this.usersEmail,
      required this.onRefresh});

  @override
  State<CabCard> createState() => _CabCardState();
}

class _CabCardState extends State<CabCard> {
  late bool _isExpanded;
  late String note;
  late String date;
  late String startTime;
  late String endTime;
  // late String id;
  late int bookingId;
  late String availableSeats;
  late String startLocation;
  late String endLocation;
  late List<Map<String, String>> travellers;

  TextEditingController commentController = TextEditingController(text: "I am interested to join.");

  String convertDateFormat(DateTime inputDate) {
    String formattedDate = DateFormat('E, d MMM y').format(inputDate);
    return formattedDate;
  }

  String formatTime(DateTime inputTime) {
    String formattedTime = DateFormat('hh:mm a').format(inputTime);
    return formattedTime;
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.inter(),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // From the API service
  ApiServices apiServices = ApiServices();

  void joinCab(BuildContext context) async {
    try {
      final res = await apiServices.requestToJoinBooking(
          bookingId, commentController.text.trim());
      if (res["status"] == 200) {
        showMessage("Successfully sent the cab join request");
      } else {
        showMessage(res['error']);
      }
    } catch (e) {
      showMessage('Something went wrong');
    }
  }

  void deleteCab() async {
    final res = await apiServices.deleteBooking(bookingId);
    if (res['status'] == 200) {
      showMessage("Cab has been successfully deleted");
    } else {
      showMessage(res['error']);
    }
  }

  void exitCab() async {
    final res = await apiServices.exitBooking(bookingId);
    if (res['status'] == 200) {
      showMessage("Successfully exited from the cab");
    } else {
      showMessage(res['error']);
    }
  }

  void cancelRequest() async {
    final res = await apiServices.deleteRequest(bookingId);
    if (res['status'] == 200) {
      showMessage("Request has been successfully canceled");
    } else {
      showMessage(res['error']);
    }
  }

  void profileDialog(String name, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Traveller Profile',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $name',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text('Email: $email',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.topCenter,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromRGBO(254, 114, 76, 0.70),
                ),
                // onPressed: () => Navigator.of(context).pop(),
                child: Text('Close',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  void requestStatusDialog(
      String name, String email, String phone, String comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Request Status',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $name',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text('Email: $email',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text('Phone: $phone',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text('Comment: $comment',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final res =
                          await apiServices.rejectRequest(bookingId, email);
                      Navigator.pop(context);
                      if (res['status'] == 200) {
                        showMessage("Successfully request rejected");
                      } else {
                        showMessage(res['error']);
                      }

                      widget.onRefresh();
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xffdc2828),
                      ),
                      child: Text('Reject',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final res =
                          await apiServices.acceptRequest(bookingId, email);
                      Navigator.pop(context);
                      if (res['status'] == 200) {
                        showMessage("Successfully request accepted");
                      } else {
                        showMessage(res['error']);
                      }
                      widget.onRefresh();
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xff16a249),
                      ),
                      child: Text('Accept',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  showConfirmationDialog(
      BuildContext context, String title, String button, Function onTap) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Confirmation',
              style:
                  GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            content: Text(
              title,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromRGBO(254, 114, 76, 0.70),
                        ),
                        child: Text('No',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        await onTap();
                        widget.onRefresh();
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xffdc2828),
                        ),
                        child: Text(button,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  bool isUserAlreadyATraveller() {
    return widget.cab.ownerEmail == widget.usersEmail ||
        widget.cab.travellers.any((t) => t.email == widget.usersEmail);
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cab = widget.cab;
    note = cab.travellers[0].comments;
    date = convertDateFormat(cab.startTime);
    startTime = formatTime(cab.startTime);
    endTime = formatTime(cab.endTime);
    // id = cab.id.toString();
    availableSeats = (cab.capacity - cab.travellers.length).toString();
    startLocation = cab.fromLoc;
    endLocation = cab.toLoc;
    bookingId = cab.id;
    travellers = cab.travellers
        .map(
          (traveller) => {
            'name': traveller.name,
            'email': traveller.email,
          },
        )
        .toList();
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(51, 51, 51, 0.10),
              offset: Offset(0, 8), // Offset in the x, y direction
              blurRadius: 21.0, // Blur radius
              spreadRadius: 0.0, // Spread radius
            ),
          ],
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          "$startTime - $endTime",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                          text: 'Available Seats  ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(255, 77, 77, 77),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: availableSeats,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(startLocation,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 8.0),
                          Flexible(
                            flex: 1,
                            child: Text(
                              endLocation,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 1),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xffADADAD),
                        size: 50,
                      ),
                    )
                  ],
                )
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: _isExpanded,
                child: Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey[200],
                              ),
                              child: Text(
                                "Note: $note",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          !isUserAlreadyATraveller()
                              ? widget.cab.requests
                                      .any((r) => r.email == widget.usersEmail)
                                  ? Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showConfirmationDialog(
                                                context,
                                                'Are you sure you want to cancel this request?',
                                                'Yes',
                                                cancelRequest);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    254, 114, 76, 0.70),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 3.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showBottomSheet(context,
                                                commentController, joinCab);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    254, 114, 76, 0.70),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 3.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text(
                                            "Join",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                              : widget.cab.ownerEmail == widget.usersEmail
                                  ? Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // deleteCab();
                                            showConfirmationDialog(
                                                context,
                                                'Are you sure you want to delete this ride?',
                                                'Yes',
                                                deleteCab);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    254, 114, 76, 0.70),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 3.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text(
                                            "Delete",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showConfirmationDialog(
                                                context,
                                                'Are you sure you want to exit from this booking?',
                                                'Yes',
                                                exitCab);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    254, 114, 76, 0.70),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 3.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text(
                                            "Exit",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                        ],
                      ),
                      widget.cab.ownerEmail == widget.usersEmail &&
                              widget.cab.requests.isNotEmpty
                          ? const SizedBox(height: 15.0)
                          : const SizedBox(),
                      widget.cab.ownerEmail == widget.usersEmail &&
                              widget.cab.requests.isNotEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Requests",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Column(
                                  children: widget.cab.requests
                                      .map(
                                        (req) => Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          margin: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  req.name,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  requestStatusDialog(
                                                      req.name,
                                                      req.email,
                                                      req.phoneNumber,
                                                      req.comments);
                                                },
                                                child: Container(
                                                  // width: 48,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: const Color.fromRGBO(
                                                        254, 114, 76, 0.70),
                                                  ),
                                                  child: Text(
                                                    'Request Status',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 15.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Travellers",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Column(
                            children: travellers
                                .map(
                                  (traveller) => Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(10.0),
                                    //   color: Colors.grey[200],
                                    // ),
                                    margin: const EdgeInsets.only(bottom: 5.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            traveller['name']!,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            profileDialog(traveller['name']!,
                                                traveller['email']!);
                                          },
                                          child: Container(
                                            // width: 48,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: const Color.fromRGBO(
                                                  254, 114, 76, 0.70),
                                            ),
                                            child: Text(
                                              'View Profile',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class Cab {
//   final int id;
//   final String startTime;
//   final String endTime;
//   final int capacity;
//   final String from;
//   final String to;
//   final String ownerEmail;
//   final List<Traveller> travellers;
//   final List<Traveller> requests;

//   Cab({
//     required this.id,
//     required this.startTime,
//     required this.endTime,
//     required this.capacity,
//     required this.from,
//     required this.to,
//     required this.ownerEmail,
//     required this.travellers,
//     required this.requests,
//   });

//   factory Cab.fromJson(Map<String, dynamic> json) {
//     return Cab(
//       id: json['id'],
//       startTime: json['start_time'],
//       endTime: json['end_time'],
//       capacity: json['capacity'],
//       from: json['from_'],
//       to: json['to'],
//       ownerEmail: json['owner_email'],
//       travellers: List<Traveller>.from(
//           json['travellers'].map((x) => Traveller.fromJson(x))),
//       requests: List<Traveller>.from(
//           json['requests'].map((x) => Traveller.fromJson(x))),
//     );
//   }
// }

// class Traveller {
//   final String email;
//   final String comments;
//   final String name;
//   final String phoneNumber;

//   Traveller({
//     required this.email,
//     required this.comments,
//     required this.name,
//     required this.phoneNumber,
//   });

//   factory Traveller.fromJson(Map<String, dynamic> json) {
//     return Traveller(
//       email: json['email'],
//       comments: json['comments'],
//       name: json['name'],
//       phoneNumber: json['phone_number'],
//     );
//   }
// }

void _showBottomSheet(BuildContext context, commentController, joinCab) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity,
            // height: context.size!.height * 0.5,
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Comment',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter a comment to help the owner understand why you want to join this ride',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your comment here',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                  maxLines: 4,
                  controller: commentController,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // if (commentController.text.trim().isEmpty) {
                        //   return;
                        // }
                        joinCab(context);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                        // alignment: Alignment.centerLeft,
                        backgroundColor:
                            const Color.fromRGBO(254, 114, 76, 0.70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

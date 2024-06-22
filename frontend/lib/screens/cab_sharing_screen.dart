import 'package:flutter/material.dart';
import 'package:frontend/screens/cab_add_screen.dart';
import 'package:frontend/widgets/cab_details.dart';
import 'package:frontend/widgets/cab_search_form.dart';
import 'package:google_fonts/google_fonts.dart';

class CabSharingScreen extends StatefulWidget {
  const CabSharingScreen({Key? key}) : super(key: key);
  @override
  State<CabSharingScreen> createState() => _CabSharingScreenState();
}

class _CabSharingScreenState extends State<CabSharingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedOption;
  String? selectedOption2;
  bool isTabOneSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Cab Sharing',
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
      floatingActionButton: SizedBox(
        height: 75.0,
        width: 75.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CabAddScreen(),
                ),
              );
            },
            backgroundColor: const Color.fromRGBO(254, 114, 76, 0.70),
            child: const Icon(
              Icons.add,
              size: 30.0,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 22.0,
            vertical: 16.0,
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                      offset: Offset(0, 4), // Offset in the x, y direction
                      blurRadius: 10.0,
                      spreadRadius: 0.0,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isTabOneSelected = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isTabOneSelected
                                  ? const Color.fromRGBO(254, 114, 76, 0.70)
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            child: Center(
                              child: Text(
                                'All Rides',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: isTabOneSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isTabOneSelected = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isTabOneSelected
                                  ? Colors.white
                                  : const Color.fromRGBO(254, 114, 76, 0.70),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            child: Center(
                              child: Text(
                                'My Rides',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: isTabOneSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              isTabOneSelected
                  ? const CabSearch()
                  : const SizedBox(
                      height: 0.0,
                    ),
              const SizedBox(height: 25.0),
              const CabCard(),
              const SizedBox(height: 25.0),
              Text(
                "End of List",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffADADAD),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

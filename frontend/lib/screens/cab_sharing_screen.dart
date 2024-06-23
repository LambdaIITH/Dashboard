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

  @override
  Widget build(BuildContext context) {
    Widget allRides = Column(
      children: [
        const CabSearch(),
        const SizedBox(height: 25.0),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (ctx, inx) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CabCard(),
            ),
          ),
        ),
      ],
    );

    Widget myRides = Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (ctx, inx) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CabCard(),
            ),
          ),
        ),
      ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CabAddScreen(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(204, 254, 115, 76),
        child: const Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
      body: Padding(
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
                borderRadius: const BorderRadius.all(Radius.circular(7.0)),
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

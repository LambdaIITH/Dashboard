import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabSearch extends StatefulWidget {
  final DateTime initialSelectedDate;
  final String? initialSelectedOption;
  final String? initialSelectedOption2;
  final Function onSearch;

  const CabSearch({
    super.key,
    required this.initialSelectedDate,
    this.initialSelectedOption,
    this.initialSelectedOption2,
    required this.onSearch,
  });

  @override
  State<CabSearch> createState() => _CabSearchState();
}

class _CabSearchState extends State<CabSearch> {
  late DateTime selectedDate = DateTime.now();
  String? selectedOption;
  String? selectedOption2;
  bool isTabOneSelected = true;
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
    selectedDate = widget.initialSelectedDate;
    selectedOption = widget.initialSelectedOption;
    selectedOption2 = widget.initialSelectedOption2;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Container(
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
                child: DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(10.0),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(10, 25, 15, 25),
                  ),
                  items: locations.map(
                    (String location) {
                      String displayText = location.length > 7
                          ? '${location.substring(0, 7)}..'
                          : location;
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(
                          displayText,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (String? value) {
                    selectedOption = value;
                  },
                  hint: selectedOption == null
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
                      color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    selectedOption2 = value;
                  },
                  hint: selectedOption2 == null
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
                      color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
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
                      Icons.calendar_today,
                      color: Color(0xffADADAD),
                    ),
                    hintText: selectedOption == null
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.sort_outlined,
              size: 30.0,
              color: Color(0xffFE724C),
            ),
            const SizedBox(width: 10.0),
            const Icon(
              Icons.filter_alt_outlined,
              size: 30.0,
              color: Color(0xffFE724C),
            ),
            const SizedBox(width: 50.0),
            // Expanded(
            //   child: TextButton(
            //     onPressed: () {
            //       setState(() {
            //         selectedDate = DateTime.now();
            //         selectedOption = null;
            //         selectedOption2 = null;
            //       });
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10.0),
            //         // color: const Color.fromRGBO(254, 114, 76, 0.70),
            //         color: Colors.grey,
            //         boxShadow: const [
            //           BoxShadow(
            //             color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
            //             offset: Offset(0, 8), // Offset in the x, y direction
            //             blurRadius: 21.0,
            //             spreadRadius: 0.0,
            //           ),
            //         ],
            //       ),
            //       height: 40,
            //       alignment: Alignment.center,
            //       child: Text(
            //         'Clear',
            //         style: GoogleFonts.inter(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.black,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(width: 50.0),
            Expanded(
              child: TextButton(
                onPressed: () {
                  widget.onSearch(
                    searchSelectedDate: selectedDate,
                    searchSelectedOption: selectedOption,
                    searchSelectedOption2: selectedOption2,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color.fromRGBO(254, 114, 76, 0.70),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                        offset: Offset(0, 8), // Offset in the x, y direction
                        blurRadius: 21.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'Search',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

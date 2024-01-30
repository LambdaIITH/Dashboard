import 'package:flutter/material.dart';
import 'package:frontend/widgets/cab_details.dart';
import 'package:google_fonts/google_fonts.dart';

class CabSharingScreen extends StatefulWidget {
  @override
  State<CabSharingScreen> createState() => _CabSharingScreenState();
}

class _CabSharingScreenState extends State<CabSharingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedOption;
  String? selectedOption2;

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
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () {},
            backgroundColor: Color.fromRGBO(254, 114, 76, 0.70),
            child: const Icon(
              Icons.add,
              size: 30.0,
            ),
          ),
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
                      items:
                          ['Campus', 'RGIA', 'Airport'].map((String location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
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
                      items: [
                        'Campus',
                        'RGIA',
                        'Airport',
                      ].map((String location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 17,
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
            CabCard(),
          ],
        ),
      ),
    );
  }
}

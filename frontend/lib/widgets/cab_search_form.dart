import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CabSearch extends StatefulWidget {
  final Function onSearch;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? from;
  final String? to;

  const CabSearch(
      {super.key,
      required this.onSearch,
      this.endDate,
      this.from,
      this.startDate,
      this.to});

  @override
  State<CabSearch> createState() => _CabSearchState();
}

class _CabSearchState extends State<CabSearch> {
  late DateTime selectedStartDate = DateTime.now();
  late DateTime selectedEndDate = DateTime.now()
      .add(const Duration(hours: 1)); 
  String? selectedOption;
  String? selectedOption2;
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
    if (widget.endDate != null) {
      selectedEndDate = widget.endDate!;
      isEndTimeSelected = true;
    }
    if (widget.startDate != null) {
      selectedStartDate = widget.startDate!;
      isStartTimeSelected = true;
    }
    if (widget.from != null) {
      selectedOption = widget.from;
      isFromSelected = true;
    }
    if (widget.to != null) {
      selectedOption2 = widget.to;
      isToSelected = true;
    }
  }

  Future<void> _selectDateTime(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = selectedStartDate;
    final DateTime initialDate = selectedStartDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay initialTime = TimeOfDay.fromDateTime(
          isStartDate ? selectedStartDate : selectedEndDate);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (pickedTime != null) {
        final DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isStartDate) {
          if (combined.isBefore(now)) {
            selectedStartDate = now;
          } else {
            selectedStartDate = combined;
          }
          if (selectedEndDate.isBefore(selectedStartDate)) {
            selectedEndDate = selectedStartDate.add(const Duration(hours: 1));
          }
          isStartTimeSelected = true;
        } else {
          if (combined.isBefore(selectedStartDate)) {
            selectedEndDate = selectedStartDate.add(const Duration(hours: 1));
          } else {
            selectedEndDate = combined;
          }
          isEndTimeSelected = true;
        }
        setState(() {});
      }
    }
  }

  bool isStartTimeSelected = false;
  bool isEndTimeSelected = false;
  bool isFromSelected = false;
  bool isToSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildLocationDropdown(selectedOption, 'From', true),
          const SizedBox(height: 12.0),
          _buildLocationDropdown(selectedOption2, 'To', false),
          const SizedBox(height: 12.0),
          _buildDateTimePicker("Start Time", selectedStartDate, true),
          const SizedBox(height: 12.0),
          _buildDateTimePicker("End Time", selectedEndDate, false),
          const SizedBox(height: 25.0),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: ((isStartTimeSelected || isEndTimeSelected) ||
                          (isFromSelected || isToSelected))
                      ? () {
                          widget.onSearch(
                            start: null,
                            end: null,
                            searchSelectedOption: null,
                            searchSelectedOption2: null,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ((isStartTimeSelected || isEndTimeSelected) ||
                              (isFromSelected || isToSelected))
                          ? const Color.fromRGBO(254, 114, 76, 0.70)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(51, 51, 51, 0.10),
                          offset: Offset(0, 8),
                          blurRadius: 21.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: ((isStartTimeSelected && isEndTimeSelected) ||
                          (isFromSelected && isToSelected))
                      ? () {
                          widget.onSearch(
                            start: isStartTimeSelected && isEndTimeSelected
                                ? selectedStartDate
                                : null,
                            end: isStartTimeSelected && isEndTimeSelected
                                ? selectedEndDate
                                : null,
                            searchSelectedOption: isFromSelected && isToSelected
                                ? selectedOption
                                : null,
                            searchSelectedOption2:
                                isToSelected && isFromSelected
                                    ? selectedOption2
                                    : null,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ((isStartTimeSelected && isEndTimeSelected) ||
                              (isFromSelected && isToSelected))
                          ? const Color.fromRGBO(254, 114, 76, 0.70)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(51, 51, 51, 0.10),
                          offset: Offset(0, 8),
                          blurRadius: 21.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Search',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown(
      String? selectedValue, String hintText, bool isFrom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(51, 51, 51, 0.10),
            offset: Offset(0, 4),
            blurRadius: 10.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        ),
        items: locations.map((location) {
          return DropdownMenuItem<String>(
            value: location,
            child: Text(location,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (isFrom) {
              selectedOption = value;
              isFromSelected = true;
            } else {
              selectedOption2 = value;
              isToSelected = true;
            }
          });
        },
        value: selectedValue,
        hint: Text(hintText,
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xffADADAD))),
      ),
    );
  }

  Widget _buildDateTimePicker(
      String label, DateTime dateTime, bool isStartDate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(51, 51, 51, 0.10),
            offset: Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: TextFormField(
        readOnly: true,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xffADADAD)),
          hintText: label,
          hintStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xffADADAD)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        ),
        onTap: () => _selectDateTime(context, isStartDate: isStartDate),
        controller: TextEditingController(
            text: isStartDate
                ? isStartTimeSelected
                    ? DateFormat('yyyy-MM-dd – kk:mm').format(dateTime)
                    : ""
                : isEndTimeSelected
                    ? DateFormat('yyyy-MM-dd – kk:mm').format(dateTime)
                    : ""),
      ),
    );
  }
}

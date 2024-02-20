import 'package:flutter/material.dart';
import 'package:frontend/widgets/calendar_item.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  String selectedViewType = "List";
  List<String> viewTypeList = ["List", "Day", "Week", "Month"];
//TODO: imlpement calendar
// packages that can be considered
// kalendar, sync fusion calendar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 30,
            shadows: [
              Shadow(
                offset: Offset(0, 1.5),
                color: Colors.black,
              )
            ],
          ),
        ),
        leadingWidth: 65,
        leading: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 40),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          );
        }),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 2,
          ),
          Row(
            children: viewTypeList.map((String viewType) {
              return iosSelectionButton(
                title: viewType,
                isSelected: selectedViewType == viewType,
                onClick: () {
                  setState(() {
                    selectedViewType = viewType;
                  });
                  debugPrint("Clicked on $viewType");
                },
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return const CalendarItem(
                    time: "9:00 AM",
                    eventhead: "Acad",
                    eventtitle: "Class",
                    eventcolor: "ad",
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget iosSelectionButton(
      {required String title, bool isSelected = false, VoidCallback? onClick}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1.5, color: Color(0xFF1C77FF)),
            backgroundColor:
                isSelected ? const Color(0xFF1C77FF) : Colors.transparent),
        onPressed: onClick,
        child: Text(title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1C77FF),
            )),
      ),
    );
  }
}

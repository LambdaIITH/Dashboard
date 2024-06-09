import 'package:flutter/material.dart';
import 'package:frontend/widgets/mess_menu_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

List breakfast = [
      '1. Aloo Paratha',
      '2. Pudina Chutney',
      '3. Curd',
      '4. Butter',
      '5. Milk',
      '6. Tea',
      '7. Bournvita',
      '8. Egg/Banana'
];

List lunch = [
      '1. Plain Roti',
      '2. Masoor Dal',
      '3. Aloo-methi',
      '4. Rice',
      '5. Curd',
      '6. Papad',
      '7. Sambar',
      '8. Salad'
];
List snacks = [
      '1. Ginger tea',
      '2. milk'
];
List dinner = [
      '1. Plain Roti',
      '2. Rajma',
      '3. Chicken/Paneer biryani',
      '4. Veg korma',
      '5. Buttermilk',
      '6. Papad',
      '7. Rice',
      '8. Salad'
];

class MessMenuScreen extends StatelessWidget {
  const MessMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mess Menu',
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
      body: const SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Expanded(child: SingleChildScrollView(child: MessMenuPage())),
        ]),
      ),
    );
  }
}

class MessMenuPage extends StatefulWidget {
  const MessMenuPage({super.key});

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage> {
  String whichDay = 'Sunday';
  final List<bool> selectedOption = [true, false];
  final List<Widget> messToggleButtons = [
    Text(
      'UDH',
      style: GoogleFonts.inter(
          fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.black),
    ),
    Text(
      'LDH',
      style: GoogleFonts.inter(
          fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.black),
    )
  ];

String getCurrentDay() {
  DateTime now = DateTime.now();
  String day = DateFormat('EEEE').format(now);
  return day;
}

  @override
  void initState() {
    whichDay = getCurrentDay();
    // _loadMessPreference();
    super.initState();
  }

  // _loadMessPreference() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int whichMess = prefs.getInt('messPref') ?? 0;
  //   setState(() {
  //     for (var i = 0; i < selectedOption.length; i++) {
  //       selectedOption[i] = i == whichMess;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 3, 0, 0),
              child: DropdownButton<String>(
                elevation: 0,
                underline: Container(),
                value: whichDay,
                items: <String>[
                  'Sunday',
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    whichDay = value!;
                  });
                },
                focusColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 3, 30, 0),
              child: ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (index) {
                    setState(() {
                      for (var i = 0; i < selectedOption.length; i++) {
                        selectedOption[i] = i == index;
                      }
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                  fillColor: const Color.fromARGB(255, 198, 198, 198),
                  constraints: const BoxConstraints(
                    minHeight: 38.0,
                    minWidth: 85.0,
                  ),
                  isSelected: selectedOption,
                  children: messToggleButtons),
            )
          ],
        ),
        Column(
          children: [
            const SizedBox(
              height: 40.0,
            ),
            ShowMessMenu(
              whichMeal: 'Breakfast',
              time: '7:30AM-10:30AM',
              meals: breakfast,
            ),
            ShowMessMenu(
              whichMeal: 'Lunch',
              time: '12:30PM-2:45PM',
              meals: lunch,
            ),
            ShowMessMenu(
              whichMeal: 'Snacks',
              time: '5:00PM-6:00PM',
              meals: snacks,
            ),
            ShowMessMenu(
              whichMeal: 'Dinner',
              time: '7:30PM-9:30PM',
              meals: dinner,
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/mess_menu_model.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/widgets/mess_menu_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dashbaord/services/mess_menu_service.dart';

class MessMenuScreen extends StatefulWidget {
  final MessMenuModel? messMenu;
  final int? week;
  const MessMenuScreen({super.key, required this.messMenu, this.week});

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  MessMenuModel? messMenu;
  bool isLoading = true;

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  int status = 0;
  int totalOperation = 1;

  void changeState() {
    setState(() {
      status++;
      if (status >= totalOperation) {
        isLoading = false;
      }
    });
  }

  int week = MessMenuService.getCurrentWeek();

  Future<void> fetchMessMenu() async {
    try {
      final response = await MessMenuService.loadWeek(week);

      setState(() {
        messMenu = response;
        changeState();
      });
    } catch (e) {
      debugPrint("Failed to load mess menu: $e");
      showError(msg: "Failed to load mess menu");
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.week != null) {
      week = widget.week!;
    }

    if (widget.messMenu == null) {
      fetchMessMenu();
    } else {
      messMenu = widget.messMenu;
      // isLoading = false;
      changeState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomLoadingScreen()
        : Scaffold(
            appBar: CustomAppBar(
              title: 'Mess Menu'
            ),
            body: SafeArea(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: MessMenuPage(
                      messMenu: messMenu!,
                      week: week,
                    ))),
                  ]),
            ),
          );
  }
}

class MessMenuPage extends StatefulWidget {
  final MessMenuModel messMenu;
  final int? week;
  const MessMenuPage({super.key, required this.messMenu, this.week});

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage> {
  late MessMenuModel messMenu;
  String whichDay = 'Sunday';
  final List<bool> selectedOption = [true, false];

  String getCurrentDay() {
    DateTime now = DateTime.now();
    String day = DateFormat('EEEE').format(now);
    return day;
  }

  final analyticsService = FirebaseAnalyticsService();

  late int week;

  @override
  void initState() {
    super.initState();
    whichDay = getCurrentDay();
    analyticsService.logScreenView(screenName: "Mess Menu Screen");
    week = widget.week ?? MessMenuService.getCurrentWeek();
    messMenu = widget.messMenu;
  }

  bool isWeekend() {
    return whichDay == 'Sunday' || whichDay == 'Saturday';
  }

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final meals = selectedOption[0]
        ? messMenu.udh[whichDay]
        : messMenu.ldh[whichDay];

    final extras = messMenu.udhAdditional[whichDay];

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
                        color: textColor,
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
                focusColor: textColor,
              ),
            ),
                Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 36, 0),
                child: DropdownButton<int>(
                  elevation: 0,
                  underline: Container(),
                  value: week,
                  items:
                      <int>[1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        "$value",
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? value) async {
                    if (value == null) {
                      return;
                    }
                    try {
                      final newMenu = await MessMenuService.loadWeek(value);
                    
                      setState(() {
                        week = value;
                        messMenu = newMenu;
                      });
                    } catch (e) {
                      debugPrint("Failed to load week $value: $e");
                      showError(msg: "Failed to load menu");
                    }
                  },
                  focusColor: textColor,
                ),
              ),
          ],
        ),
        Column(
          children: [
            const SizedBox(
              height: 8.0,
            ),
            if (meals != null) ...[
              ShowMessMenu(
                extras: extras?.breakfast ?? [],
                whichMeal: 'Breakfast',
                time: isWeekend()? '7:30AM-10:30AM' : '7:30AM-10:00AM',
                meals: meals.breakfast,
              ),
              ShowMessMenu(
                extras: extras?.lunch ?? [],
                whichMeal: 'Lunch',
                time:   '12:30PM-2:45PM',
                meals: meals.lunch,
              ),
              ShowMessMenu(
                extras: extras?.snacks ?? [],
                whichMeal: 'Snacks',
                time: '5:00PM-6:00PM',
                meals: meals.snacks,
              ),
              ShowMessMenu(
                extras: extras?.dinner ?? [],
                whichMeal: 'Dinner',
                time: '7:30PM-9:30PM',
                meals: meals.dinner,
              ),
            ] else
              const Center(child: Text('No meals available for today')),
          ],
        ),
      ],
    );
  }
}

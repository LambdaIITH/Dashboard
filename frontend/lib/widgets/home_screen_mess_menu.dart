import 'package:flutter/material.dart';
import 'package:frontend/models/mess_menu_model.dart';
import 'package:frontend/screens/mess_menu_screen.dart';
import 'package:frontend/widgets/home_mess_component.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreenMessMenu extends StatelessWidget {
  final MessMenuModel? messMenu;
  const HomeScreenMessMenu({
    super.key,
    this.messMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (messMenu == null) {
      return noMealToday("Failed to fetch mess menu", context);
    }

    final String today = DateFormat('EEEE').format(DateTime.now());
    final meals = messMenu?.ldh[today]; // or use messMenu.udh[today]

    if (meals == null) {
      return noMealToday("Failed to fetch mess menu", context);
    }

    final currentTime = TimeOfDay.now();
    String currentMeal;
    List<String> currentMealData;
    String mealTime;

    if (currentTime.hour < 10 ||
        (currentTime.hour == 10 && currentTime.minute <= 30)) {
      currentMeal = 'Breakfast';
      currentMealData = meals.breakfast;
      mealTime = '7:30AM-10:30AM';
    } else if (currentTime.hour < 14 ||
        (currentTime.hour == 14 && currentTime.minute <= 45)) {
      currentMeal = 'Lunch';
      currentMealData = meals.lunch;
      mealTime = '12:30PM-2:45PM';
    } else if (currentTime.hour < 17 ||
        (currentTime.hour == 17 && currentTime.minute <= 0)) {
      currentMeal = 'Snacks';
      currentMealData = meals.snacks;
      mealTime = '5:00PM-6:00PM';
    } else if (currentTime.hour < 24 ||
        (currentTime.hour == 24 && currentTime.minute <= 0)) {
      currentMeal = 'Dinner';
      currentMealData = meals.dinner;
      mealTime = '7:30PM-9:30PM';
    } else {
      return noMealToday('No meals available for today', context);
    }

    return InkWell(
      onTap: () {
        if (messMenu == null) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => MessMenuScreen(messMenu: messMenu!)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
              offset: Offset(0, 4), // Offset in the x, y direction
              blurRadius: 10.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18, top: 15),
                child: Text(
                  'Mess Menu',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            HomeMessMenu(
              whichMeal: currentMeal,
              meals: currentMealData,
              time: mealTime,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget noMealToday(String msg, BuildContext context) {
    return InkWell(
      onTap: () {
        if (messMenu == null) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => MessMenuScreen(messMenu: messMenu!)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
              offset: Offset(0, 4), // Offset in the x, y direction
              blurRadius: 10.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18, top: 15),
                child: Text(
                  'Mess Menu',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

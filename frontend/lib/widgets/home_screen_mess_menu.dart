import 'package:flutter/material.dart';
import 'package:frontend/screens/mess_menu_screen.dart';
import 'package:frontend/widgets/mess_menu_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenMessMenu extends StatelessWidget {
  const HomeScreenMessMenu({
    super.key,
  });

  static const List breakfast = [
    'Aloo Paratha',
    'Pudina Chutney',
    'Curd',
    'Butter',
    'Milk',
    'Tea',
    'Bournvita',
    'Egg/Banana',
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MessMenuScreen()),
      ),
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
                  'Mess',
                  style: GoogleFonts.inter().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              child: ShowMessMenu(
                whichMeal: 'Breakfast',
                meals: breakfast,
                time: '7:30AM-10:30AM',
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

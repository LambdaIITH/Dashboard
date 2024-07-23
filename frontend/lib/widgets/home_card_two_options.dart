import 'package:flutter/material.dart';
import 'package:dashbaord/widgets/home_card_option.dart';

class HomeCardTwoOptions extends StatelessWidget {
  final String title;
  final String title1;
  final String title2;
  final String image1;
  final String image2;
  final List<void Function()>? onTap;

  const HomeCardTwoOptions({
    super.key,
    required this.title,
    this.onTap,
    required this.title1,
    required this.title2,
    required this.image1,
    required this.image2,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 160,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 14,
              left: 18,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeCardOption(
                  title: title1,
                  image: image1,
                  onTap: onTap?[0],
                ),
                SizedBox(width: 0.06 * screenWidth),
                HomeCardOption(
                  title: title2,
                  image: image2,
                  onTap: onTap?[1],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

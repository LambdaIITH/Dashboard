import 'package:flutter/material.dart';
import 'package:frontend/constants/enums/lost_and_found.dart';
import 'package:frontend/utils/bold_text.dart';
import 'package:frontend/widgets/lost_found_add_item.dart';
import 'package:frontend/widgets/lost_found_item.dart';

class LostAndFoundScreen extends StatelessWidget {
  const LostAndFoundScreen({super.key});

  double getAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 450) {
      return 0.9;
    }
    else if (screenWidth > 400) {
      return 0.8;
    } else if (screenWidth <= 400 && screenWidth > 370) {
      return 0.7;
    } else if (screenWidth > 350){
      return 0.65;
    } else {
      return 0.6;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BoldText(
          text: 'Lost and Found',
          color: Colors.black,
          size: 28,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Color(0xB2FE724C),
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: getAspectRatio(context),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: const [
            LostFoundAddItem(),
            LostFoundItem(
              itemName: 'Mini Grater',
              lostOrFound: LostOrFound.lost,
              images: [
                'assets/lost_and_found/lost-found-grater.png',
                'assets/lost_and_found/lost-found-grater.png',
                'assets/lost_and_found/lost-found-grater.png',
              ],
            ),
            LostFoundItem(
              itemName: 'Highlighter',
              lostOrFound: LostOrFound.found,
              images: [
                'assets/lost_and_found/highlighter.png',
                'assets/lost_and_found/lost-found-grater.png',
              ],
            ),
            LostFoundItem(
              itemName: 'Calculator',
              lostOrFound: LostOrFound.lost,
              images: [
                'assets/lost_and_found/calculator.png',
                'assets/lost_and_found/lost-found-grater.png',
                'assets/lost_and_found/lost-found-grater.png',
              ],
            ),
            LostFoundItem(
              itemName: 'Batteries',
              lostOrFound: LostOrFound.lost,
              images: [
                'assets/lost_and_found/batteries.png',
                'assets/lost_and_found/lost-found-grater.png',
                'assets/lost_and_found/lost-found-grater.png',
              ],
            ),
            LostFoundItem(
              itemName: 'Samsung Adapter',
              lostOrFound: LostOrFound.found,
              images: [
                'assets/lost_and_found/samsung-adapter.png',
                'assets/lost_and_found/lost-found-grater.png',
                'assets/lost_and_found/lost-found-grater.png',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

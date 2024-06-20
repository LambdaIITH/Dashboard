import 'package:flutter/material.dart';
import 'package:frontend/constants/enums/lost_and_found.dart';
import 'package:frontend/screens/lost_and_found_item_screen.dart';
import 'package:frontend/utils/normal_text.dart';
import 'package:frontend/widgets/custom_carousel.dart';

class LostFoundItem extends StatelessWidget {
  const LostFoundItem({
    super.key,
    required this.itemName,
    required this.images,
    required this.lostOrFound,
  });

  final String itemName;
  final LostOrFound lostOrFound;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LostAndFoundItemScreen(
            images: images,
            itemName: itemName,
            itemDescription:
                'Green highlighter found near the canteen on 20th october.',
            lostOrFound: lostOrFound,
          ),
        ),
      ),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
              offset: Offset(0, 4), // Offset in the x, y direction
              blurRadius: 10.0,
              spreadRadius: 0.0,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCarousel(
              images: images,
              fromMemory: false,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: NormalText(
                text: itemName,
                size: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: NormalText(
                text: lostOrFound == LostOrFound.lost ? 'Lost' : 'Found',
                size: 16,
                color: const Color(0xB2FE724C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

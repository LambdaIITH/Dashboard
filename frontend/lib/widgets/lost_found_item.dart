import 'package:flutter/material.dart';
import 'package:frontend/constants/enums/lost_and_found.dart';
import 'package:frontend/models/lost_and_found_model.dart';
import 'package:frontend/screens/lost_and_found_item_screen.dart';
import 'package:frontend/utils/normal_text.dart';
import 'package:frontend/widgets/custom_carousel.dart';

class LostFoundItem extends StatelessWidget {
  const LostFoundItem({
    super.key,
    required this.item,
  });

  final LostAndFoundModel item;

  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LostAndFoundItemScreen(
            id: item.id,
            lostOrFound: item.lostOrFound,
          ),
        ),
      ),
      child: Container(
        width: 160, // Fixed height
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 210, 47, 47),
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
            // Using Expanded to ensure the Carousel takes the available space
            Expanded(
              child: CustomCarousel(
                images: item.images,
                fromMemory: false,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: NormalText(
                          text: item.itemName,
                          size: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: NormalText(
                          text: item.lostOrFound == LostOrFound.lost
                              ? 'Lost'
                              : 'Found',
                          size: 16,
                          color: const Color(0xB2FE724C),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
            ),
          ],
        ),
      ),
    );
  }
}

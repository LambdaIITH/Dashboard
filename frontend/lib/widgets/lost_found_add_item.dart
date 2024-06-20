import 'package:flutter/material.dart';
import 'package:frontend/screens/lost_and_found_add_item_screen.dart';
import 'package:frontend/utils/normal_text.dart';

class LostFoundAddItem extends StatelessWidget {
  const LostFoundAddItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            height: 150,
            child: Center(
              child: IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LostAndFoundAddItemScreen(),
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  size: 80,
                  color: Color(0xB2FE724C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: NormalText(
                text: 'Add a Listing',
                size: 16,
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

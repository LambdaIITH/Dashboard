import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/constants/enums/lost_and_found.dart';
import 'package:frontend/utils/bold_text.dart';
import 'package:frontend/utils/normal_text.dart';
import 'package:frontend/widgets/custom_carousel.dart';

class LostAndFoundItemScreen extends StatelessWidget {
  const LostAndFoundItemScreen({
    super.key,
    required this.images,
    required this.itemName,
    required this.itemDescription,
    required this.lostOrFound,
  });
  final List<String> images;
  final String itemName;
  final String itemDescription;
  final LostOrFound lostOrFound;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const BoldText(
          text: 'Listings',
          color: Colors.black,
          size: 28,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: double.infinity,
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
          child: ListView(
            children: [
              CustomCarousel(
                images: images,
                height: 350,
                fromMemory: false,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: min(300, screenWidth * 0.35),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: NormalText(
                        text: itemName,
                        size: 18,
                      ),
                    ),
                    Container(
                      width: min(300, screenWidth * 0.35),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: NormalText(
                        text:
                            lostOrFound == LostOrFound.lost ? 'Lost' : 'Found',
                        size: 18,
                        color: const Color(0xB2FE724C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: NormalText(text: itemDescription),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: max(screenWidth * 0.28, 20),
                ),
                title: FilledButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith(
                      (_) => const Color(0xB2FE724C),
                    ),
                  ),
                  child: const Text('Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

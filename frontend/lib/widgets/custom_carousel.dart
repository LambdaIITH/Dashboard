import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({
    super.key,
    required this.images,
    this.height = 150,
    required this.fromMemory,
  });
  final List<String> images;
  final double height;
  final bool fromMemory;

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            height: widget.height,
            onPageChanged: (index, reason) {
              setState(() {
                selectedIndex = index;
              });
            },
            initialPage: 0,
          ),
          items: widget.images
              .map(
                (item) => widget.fromMemory == false
                    ? Image.network(
                        item,
                        fit: BoxFit.fill,
                      )
                    : Image.file(
                        File(item),
                        fit: BoxFit.fitWidth,
                      ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.images.length; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: i == selectedIndex
                      ? const Color(0xB2FE724C)
                      : Colors.black12,
                ),
              )
          ],
        )
      ],
    );
  }
}

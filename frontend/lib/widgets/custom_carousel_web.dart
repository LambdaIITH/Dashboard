
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomCarouselWeb extends StatefulWidget {
  const CustomCarouselWeb({
    super.key,
    required this.imagesWeb,
    this.height = 150,
  });
  final List<Uint8List> imagesWeb;
  final double height;

  @override
  State<CustomCarouselWeb> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarouselWeb> {
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
            items: widget.imagesWeb
                .map(
                  (item) => Image.memory(
                    item,
                    fit: BoxFit.fitWidth,
                  ),
                )
                .toList()),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.imagesWeb.length; i++)
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

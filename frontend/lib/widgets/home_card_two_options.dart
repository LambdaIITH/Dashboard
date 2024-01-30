import 'package:flutter/material.dart';
import 'package:frontend/widgets/home_card_option.dart';

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
    return Card(
      elevation: 3,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: SizedBox(
        height: 160,
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
                  const SizedBox(width: 30),
                  HomeCardOption(
                    title: title2,
                    image: image2,
                    onTap: onTap?[0],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

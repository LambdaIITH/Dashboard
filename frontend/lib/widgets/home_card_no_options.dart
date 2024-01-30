import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeCardNoOptions extends StatelessWidget {
  final String title;
  final String image;
  final void Function()? onTap;
  const HomeCardNoOptions({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SizedBox(
          height: 140,
          child: Stack(
            children: [
              Positioned(
                top: 15,
                left: 18,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              Positioned(
                bottom: -13,
                right: -7,
                child: SvgPicture.asset(
                  image,
                  width: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

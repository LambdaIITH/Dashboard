import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeCardOption extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String image;
  const HomeCardOption({
    super.key,
    this.onTap,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: const Color(0xFFF3F3F3),
        surfaceTintColor: const Color(0xFFF3F3F3),
        elevation: 3,
        child: SizedBox(
          height: 68,
          width: 140,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: image.endsWith('svg')
                    ? SvgPicture.asset(
                        image,
                        height: 50,
                      )
                    : Image.asset(
                        image,
                        height: 50,
                      ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Color(0xff454545),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        color: const Color(0xFFF3F3F3),
        surfaceTintColor: const Color(0xFFF3F3F3),
        elevation: 3,
        child: SizedBox(
          height: 68,
          width: 0.38 * screenWidth,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: image.endsWith('svg')
                    ? SvgPicture.asset(
                        image,
                        height: 0.12 * screenWidth,
                      )
                    : Image.asset(
                        image,
                        height: 0.12 * screenWidth,
                      ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: SizedBox(
                    width: 0.3 * screenWidth,
                    child: Text(
                      title,
                      style: GoogleFonts.inter().copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: const Color(0xff454545),
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

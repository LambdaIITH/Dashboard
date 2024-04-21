import 'package:flutter/material.dart';

class DrawerOption extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  const DrawerOption({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                offset: Offset(0, 4), // Offset in the x, y direction
                blurRadius: 10.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                  color: Color(0xff454545),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

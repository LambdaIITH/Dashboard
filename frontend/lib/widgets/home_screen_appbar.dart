import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenAppBar extends StatelessWidget {
  const HomeScreenAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Good Morning\n',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              TextSpan(
                text: 'Adhith T',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ));
          },
          child: ClipOval(
            child: CircleAvatar(
              radius: 26,
              child: Image.asset('assets/icons/profile-photo.jpeg'),
            ),
          ),
        )
      ],
    );
  }
}

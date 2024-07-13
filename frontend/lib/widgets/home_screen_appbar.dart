import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenAppBar extends StatelessWidget {
  const HomeScreenAppBar({super.key, required this.user, required this.image});
  final UserModel? user;
  final String image;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$greeting\n',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              TextSpan(
                text: user?.name.split(' ').first ?? 'User',
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
            if (user == null) {
              return;
            }
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ));
          },
          child: ClipOval(
            child: CircleAvatar(radius: 24, child: Image.network(image)),
          ),
        )
      ],
    );
  }
}

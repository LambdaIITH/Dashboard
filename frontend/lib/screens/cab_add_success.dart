import 'package:flutter/material.dart';
import 'package:dashbaord/screens/cab_sharing_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CabAddSuccess extends StatelessWidget {
  final String usersEmail;
  const CabAddSuccess({Key? key, required this.usersEmail}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CabSharingScreen(
              usersEmail: usersEmail,
            ),
          ),
        );
      });
    });
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/cab-add-success.png",
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 35),
              Text(
                "Your cab is added",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff272D2F),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You will be notified when someone joins",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff272D2F),
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}

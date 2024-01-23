import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/google_button.dart';
import 'package:frontend/widgets/login_guest.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.timeDilation = 1.0});
  final double timeDilation;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    timeDilation = widget.timeDilation;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 100, 32, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: RichText(
                        text: TextSpan(
                            text: "Welcome to\n",
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff454545),
                            ),
                            children: [
                          TextSpan(
                            text: "Campus\nCompanion",
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff272D2F),
                            ),
                          )
                        ])),
                  ),
                  Hero(
                    tag: "splash_icon",
                    child: Image.asset(
                      "assets/icons/Icon.png",
                      height: 85,
                      width: 85,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 42,
              ),
              Text(
                "Sign in to continue",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xff555555),
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              const ContinueAsGuest(),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                alignment: Alignment.center,
                child: Text(
                  "Or",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xffBDBDBD),
                  ),
                ),
              ),
              const CustomGoogleButton(),
              const SizedBox(
                height: 42,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

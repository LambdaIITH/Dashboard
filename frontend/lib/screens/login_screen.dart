import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dashbaord/widgets/google_button.dart';
import 'package:dashbaord/widgets/login_guest.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class LoginScreenWrapper extends StatelessWidget {
  final double timeDilationFactor;
  final ValueChanged<int> onThemeChanged;

  const LoginScreenWrapper(
      {super.key, this.timeDilationFactor = 1.0, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    timeDilation = timeDilationFactor;
    return WillPopScope(
      onWillPop: () async {
        timeDilation = 1.0;
        return true;
      },
      child: LoginScreen(
        timeDilation: timeDilationFactor,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final ValueChanged<int> onThemeChanged;
  const LoginScreen(
      {super.key, this.timeDilation = 1.0, required this.onThemeChanged});
  final double timeDilation;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    timeDilation = widget.timeDilation;
  }

  @override
  void dispose() {
    timeDilation = 1.0; // Reset to default
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Theme.of(context).scaffoldBackgroundColor),
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
                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xff454545) : const Color.fromARGB(255, 180, 180, 180),
                        ),
                        children: [
                          TextSpan(
                            text: "IITH\nDashboard",
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color:  Theme.of(context).brightness == Brightness.light ? const Color(0xff272D2F) : const Color.fromARGB(255, 162, 162, 162),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Hero(
                    tag: "splash_icon",
                    child: Image.asset(
                      "assets/icons/logo.png",
                      height: 115,
                      width: 115,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              Text(
                "Sign in to continue",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xff555555) : const Color.fromARGB(255, 192, 192, 192) ,
                ),
              ),
              const SizedBox(height: 28),
              ContinueAsGuest(
                onThemeChanged: widget.onThemeChanged,
              ),
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
              CustomGoogleButton(
                onThemeChanged: widget.onThemeChanged,
              ),
              const SizedBox(height: 42),
            ],
          ),
        ),
      ),
    );
  }
}

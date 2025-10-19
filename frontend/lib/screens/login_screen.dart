import 'package:dashbaord/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dashbaord/widgets/google_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class LoginScreenWrapper extends StatelessWidget {
  final double timeDilationFactor;
  final ValueChanged<int> onThemeChanged;
  final String? code;

  const LoginScreenWrapper(
      {super.key,
      this.timeDilationFactor = 1.0,
      required this.onThemeChanged,
      this.code});

  @override
  Widget build(BuildContext context) {
    timeDilation = timeDilationFactor;
    return WillPopScope(
      onWillPop: () async {
        timeDilation = 1.0;
        return true;
      },
      child: LoginScreen(
        code: code,
        timeDilation: timeDilationFactor,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final ValueChanged<int> onThemeChanged;
  final String? code;

  const LoginScreen(
      {super.key,
      this.timeDilation = 1.0,
      required this.onThemeChanged,
      this.code});
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
    timeDilation = 1.0; 
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 100, 32, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // spacing: 50,
                  children: [
                    Image(image: AssetImage('assets/icons/logo.png')),
                    Text(
                      "Welcome to",
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "IITH",
                          style: GoogleFonts.inter(
                            color:
                                Theme.of(context).textTheme.displayLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          "Dashboard",
                          style: GoogleFonts.inter(
                            color: context.customColors.customAccentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomGoogleButton(onThemeChanged: widget.onThemeChanged,code: widget.code,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

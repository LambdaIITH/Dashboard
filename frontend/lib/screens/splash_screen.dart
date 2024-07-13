import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen(
      {super.key,
      this.isLoading = true,
      required this.nextPage,
      this.delay =
          const Duration(milliseconds: 900 /*TODO: change accordingly*/)});
  final Widget nextPage;
  final Duration delay;
  final bool isLoading;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  openNextPage() {
    Future.delayed(widget.delay, () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => widget.nextPage));
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      openNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.white),
      ),
      body: Stack(
        children: [
          Center(
              child: Hero(
            tag: "splash_icon",
            child: Image.asset(
              "assets/icons/Icon.png",
              height: 150,
              width: 150,
            ),
          )),
          Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(bottom: 48),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "Campus", //TODO: change this
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff272D2F),
                  ),
                  children: [
                    TextSpan(
                      text: "\nCompanion", //TODO: change this
                      style: GoogleFonts.inter(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff272D2F),
                      ),
                    )
                  ]),
            ),
          )
        ],
      ),
    );
  }
}

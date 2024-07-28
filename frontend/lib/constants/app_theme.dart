import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color customContainerColor;
  final Color customTextColor;
  final Color customShadowColor;
  final Color customBusScheduleColor;

  CustomColors({
    required this.customContainerColor,
    required this.customTextColor,
    required this.customShadowColor,
    required this.customBusScheduleColor,
  });

  @override
  CustomColors copyWith({
    Color? customContainerColor,
    Color? customTextColor,
    Color? customShadowColor,
    Color? customBusScheduleColor,
  }) {
    return CustomColors(
      customContainerColor: customContainerColor ?? this.customContainerColor,
      customTextColor: customTextColor ?? this.customTextColor,
      customShadowColor: customShadowColor ?? this.customShadowColor,
      customBusScheduleColor:
          customBusScheduleColor ?? this.customBusScheduleColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      customContainerColor:
          Color.lerp(customContainerColor, other.customContainerColor, t)!,
      customTextColor: Color.lerp(customTextColor, other.customTextColor, t)!,
      customShadowColor:
          Color.lerp(customShadowColor, other.customShadowColor, t)!,
      customBusScheduleColor:
          Color.lerp(customBusScheduleColor, other.customBusScheduleColor, t)!,
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
  primaryColor: const Color.fromARGB(255, 255, 255, 255),
  appBarTheme: AppBarTheme(
    color: const Color.fromARGB(255, 255, 255, 255),
    scrolledUnderElevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    titleTextStyle: GoogleFonts.inter(color: Colors.black),
  ),
  cardColor: Colors.white,
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.inter(color: Colors.black),
    bodyMedium: GoogleFonts.inter(color: Colors.black45),
    displayLarge: GoogleFonts.inter(color: Colors.black),
    displayMedium: GoogleFonts.inter(color: Colors.black),
    displaySmall: GoogleFonts.inter(color: Colors.black),
    headlineMedium: GoogleFonts.inter(color: Colors.black),
    headlineSmall: GoogleFonts.inter(color: Colors.black),
    titleLarge: GoogleFonts.inter(
        color: const Color(0xff6A6A6A)), //next bus card text color
    titleMedium: GoogleFonts.inter(color: Colors.white), //next bus card color
    titleSmall: GoogleFonts.inter(color: const Color(0xff404040)),
    bodySmall: GoogleFonts.inter(
        color: const Color.fromARGB(255, 114, 114, 114)), //mess card time
    labelLarge: GoogleFonts.inter(
      color: const Color(0xff292929),
    ), // mess meals
    labelSmall: GoogleFonts.inter(color: Colors.black),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColors(
      customContainerColor: Colors.white,
      customTextColor: Colors.blueGrey[900]!,
      customShadowColor: const Color.fromRGBO(51, 51, 51, 0.10),
      customBusScheduleColor: const Color.fromARGB(102, 229, 229, 229),
    ),
  ],
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xff121212),
  primaryColor: const Color.fromARGB(255, 16, 16, 16),
  appBarTheme: AppBarTheme(
    color: const Color(0xff121212),
    scrolledUnderElevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.inter(color: Colors.white),
  ),
  cardColor: const Color.fromARGB(255, 48, 48, 48),
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.inter(color: Colors.white),
    bodyMedium: GoogleFonts.inter(color: Colors.white54),
    displayLarge: GoogleFonts.inter(color: Colors.white),
    displayMedium: GoogleFonts.inter(color: Colors.white),
    displaySmall: GoogleFonts.inter(color: Colors.white),
    headlineMedium: GoogleFonts.inter(color: Colors.white),
    headlineSmall: GoogleFonts.inter(color: Colors.white),
    titleLarge: GoogleFonts.inter(
        color: const Color.fromARGB(255, 214, 214, 214)), //next bus card text color
    titleMedium: GoogleFonts.inter(
        color: const Color.fromARGB(255, 38, 38, 38)), //next bus card color
    titleSmall: GoogleFonts.inter(
        color: const Color.fromARGB(255, 170, 170, 170)), //mess card time
    bodySmall: GoogleFonts.inter(color: const Color.fromARGB(255, 201, 201, 201)),
    labelLarge: GoogleFonts.inter(
      color: const Color.fromARGB(255, 206, 206, 206),
    ), // mess meals
    labelSmall: GoogleFonts.inter(color: Colors.white),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColors(
      customContainerColor: const Color(0xff292929),
      customTextColor: Colors.blueGrey[50]!,
      customShadowColor: const Color.fromRGBO(72, 72, 72, 0.259),
      customBusScheduleColor: const Color.fromARGB(102, 56, 56, 56),
    ),
  ],
);

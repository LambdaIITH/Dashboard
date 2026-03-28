import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingScreen extends StatelessWidget {
  const CustomLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CustomLoadingIndicator(),
      ),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;

  const CustomLoadingIndicator({
    super.key,
    this.width = 150,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/Dashboard-Logo-Big.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

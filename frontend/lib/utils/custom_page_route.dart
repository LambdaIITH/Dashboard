import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final Offset startPos;
  CustomPageRoute({required this.child, this.startPos = const Offset(1, 0)})
      : super(pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: startPos, end: const Offset(0, 0)).animate(
          CurvedAnimation(
              parent: animation,
              curve:
                  const Interval(0, 0.55))
          ),
      child: child,
    );
  }
}
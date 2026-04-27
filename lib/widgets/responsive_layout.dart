import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  const ResponsiveLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalPadding;
    if (screenWidth < 400) {
      horizontalPadding = 12;
    } else if (screenWidth < 800) {
      horizontalPadding = 20;
    } else {
      horizontalPadding = 40;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
      child: child,
    );
  }
}

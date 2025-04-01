import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
          MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Adaptive sizing helpers
  static double adaptiveSize(BuildContext context, double size) {
    final screenWidth = getScreenWidth(context);
    // Base width for reference (common mobile width)
    const baseWidth = 375.0;

    return size * (screenWidth / baseWidth);
  }

  static double adaptiveFontSize(BuildContext context, double size) {
    // Cap font scaling to prevent extremely large fonts
    final scaleFactor = MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
    return adaptiveSize(context, size) * scaleFactor;
  }

  static EdgeInsets adaptivePadding(
      BuildContext context, {
        double horizontal = 0.0,
        double vertical = 0.0,
      }) {
    return EdgeInsets.symmetric(
      horizontal: adaptiveSize(context, horizontal),
      vertical: adaptiveSize(context, vertical),
    );
  }

  // Screen size breakpoints for responsive design
  static double get mobileBreakpoint => 650;
  static double get tabletBreakpoint => 1100;

  // Determine orientation
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // Safely get bottom padding for notches
  static double safeBottomPadding(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;
}

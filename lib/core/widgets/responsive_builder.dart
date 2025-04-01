import 'package:flutter/material.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop!;
    }

    if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}

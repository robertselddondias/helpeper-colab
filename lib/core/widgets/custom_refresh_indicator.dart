import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? ColorConstants.primaryColor,
      backgroundColor: Colors.white,
      displacement: 20,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}

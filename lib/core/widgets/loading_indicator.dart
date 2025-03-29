import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.size = 36.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? ColorConstants.primaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

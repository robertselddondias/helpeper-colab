import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';

class ProgressIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? label;

  const ProgressIndicator({
    Key? key,
    this.size = 36.0,
    this.color,
    this.strokeWidth = 3.0,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color ?? ColorConstants.primaryColor,
            strokeWidth: strokeWidth,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 12),
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              color: color ?? ColorConstants.primaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

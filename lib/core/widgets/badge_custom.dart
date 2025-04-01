import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';

class BadgeCustom extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final double verticalPadding;
  final double horizontalPadding;
  final double borderRadius;
  final IconData? icon;
  final VoidCallback? onTap;
  final FontWeight fontWeight;
  final double padding;

  const BadgeCustom({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.verticalPadding = 4,
    this.horizontalPadding = 8,
    this.borderRadius = 12,
    this.icon,
    this.onTap,
    this.fontWeight = FontWeight.w500,
    this.padding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize + 2,
                color: textColor ?? ColorConstants.primaryColor,
              ),
              SizedBox(width: padding > 0 ? padding : 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor ?? ColorConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

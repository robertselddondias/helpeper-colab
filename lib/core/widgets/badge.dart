import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class Badge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final double verticalPadding;
  final double horizontalPadding;
  final double borderRadius;
  final IconData? icon;
  final VoidCallback? onTap;

  const Badge({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.adaptiveSize(context, verticalPadding),
          horizontal: ResponsiveUtils.adaptiveSize(context, horizontalPadding),
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.adaptiveSize(context, borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: ResponsiveUtils.adaptiveSize(context, fontSize + 2),
                color: textColor ?? ColorConstants.primaryColor,
              ),
              SizedBox(width: ResponsiveUtils.adaptiveSize(context, 4)),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, fontSize),
                fontWeight: FontWeight.w500,
                color: textColor ?? ColorConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

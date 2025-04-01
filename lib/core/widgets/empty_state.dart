import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/widgets/animated_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? svgAsset;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double? iconSize;

  const EmptyState({
    Key? key,
    required this.title,
    required this.description,
    this.svgAsset,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: iconSize ?? ResponsiveUtils.adaptiveSize(context, 120),
                height: iconSize ?? ResponsiveUtils.adaptiveSize(context, 120),
              )
            else if (icon != null)
              Icon(
                icon,
                size: iconSize ?? ResponsiveUtils.adaptiveSize(context, 80),
                color: ColorConstants.textSecondaryColor,
              ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 24)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),
            Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                color: ColorConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: ResponsiveUtils.adaptiveSize(context, 24)),
              SizedBox(
                width: ResponsiveUtils.isMobile(context)
                    ? double.infinity
                    : ResponsiveUtils.adaptiveSize(context, 200),
                child: AnimatedButton(
                  label: buttonText!,
                  onPressed: onButtonPressed!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

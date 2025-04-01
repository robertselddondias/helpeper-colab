import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasShadow;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 16,
    this.hasShadow = true,
    this.onTap,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.adaptiveSize(context, borderRadius),
          ),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
          boxShadow: hasShadow
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

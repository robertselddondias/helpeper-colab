import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final bool iconAfterText;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isFullWidth = true,
    this.isLoading = false,
    this.icon,
    this.iconAfterText = false,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12.0;
      case ButtonSize.medium:
        return 14.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? ColorConstants.primaryColor,
            foregroundColor: textColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size == ButtonSize.small ? 16 : 24,
            ),
          ),
          child: _buildButtonContent(context),
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? ColorConstants.accentColor,
            foregroundColor: textColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size == ButtonSize.small ? 16 : 24,
            ),
          ),
          child: _buildButtonContent(context),
        );
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? ColorConstants.primaryColor,
            side: BorderSide(
              color: backgroundColor ?? ColorConstants.primaryColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size == ButtonSize.small ? 16 : 24,
            ),
          ),
          child: _buildButtonContent(context),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? ColorConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size == ButtonSize.small ? 16 : 24,
            ),
          ),
          child: _buildButtonContent(context),
        );
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: type == ButtonType.outline || type == ButtonType.text
              ? ColorConstants.primaryColor
              : Colors.white,
          strokeWidth: 2.0,
        ),
      );
    }

    if (icon == null) {
      return Text(
        label,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!iconAfterText)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(icon, size: _getFontSize() + 4),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (iconAfterText)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(icon, size: _getFontSize() + 4),
          ),
      ],
    );
  }
}

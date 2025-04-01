import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconAfterText;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonType type;

  const AnimatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconAfterText = false,
    this.backgroundColor,
    this.textColor,
    this.type = ButtonType.primary,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              height: ResponsiveUtils.adaptiveSize(context, 48),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                border: widget.type == ButtonType.outline
                    ? Border.all(
                  color: widget.backgroundColor ?? ColorConstants.primaryColor,
                  width: 1.5,
                )
                    : null,
                boxShadow: widget.type != ButtonType.outline && widget.type != ButtonType.text
                    ? [
                  BoxShadow(
                    color: (_getBackgroundColor()).withOpacity(_isPressed ? 0.2 : 0.3),
                    blurRadius: 8,
                    offset: Offset(0, _isPressed ? 2 : 3),
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: _buildContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: widget.type == ButtonType.outline || widget.type == ButtonType.text
              ? widget.textColor ?? ColorConstants.primaryColor
              : Colors.white,
          strokeWidth: 2.0,
        ),
      );
    }

    if (widget.icon == null) {
      return Text(
        widget.label,
        style: TextStyle(
          fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.iconAfterText)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(widget.icon, size: 20, color: _getTextColor()),
          ),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        if (widget.iconAfterText)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(widget.icon, size: 20, color: _getTextColor()),
          ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return widget.backgroundColor ?? ColorConstants.primaryColor;
      case ButtonType.secondary:
        return widget.backgroundColor ?? ColorConstants.accentColor;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
      default:
        return widget.backgroundColor ?? ColorConstants.primaryColor;
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;

    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return widget.backgroundColor ?? ColorConstants.primaryColor;
      default:
        return Colors.white;
    }
  }
}

enum ButtonType { primary, secondary, outline, text }

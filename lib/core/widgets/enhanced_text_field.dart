import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class EnhancedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? suffix;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool showCounter;
  final bool readOnly;
  final VoidCallback? onTap;

  // New properties for enhanced functionality
  final bool autoFocus;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;

  const EnhancedTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.prefixIcon,
    this.suffix,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.showCounter = false,
    this.readOnly = false,
    this.onTap,
    this.autoFocus = false,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 16,
    this.textColor,
    this.labelColor,
    this.hintColor,
  }) : super(key: key);

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_handleFocusChange);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }

    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: widget.labelColor ?? ColorConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: (widget.borderColor ?? ColorConstants.primaryColor).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: _obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
              fontWeight: FontWeight.normal,
              color: widget.textColor ?? (widget.enabled
                  ? ColorConstants.textPrimaryColor
                  : ColorConstants.textSecondaryColor),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: widget.fillColor ?? (widget.enabled
                  ? ColorConstants.inputFillColor
                  : ColorConstants.disabledColor),
              counterText: widget.showCounter ? null : '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.adaptiveSize(context, 20),
                vertical: ResponsiveUtils.adaptiveSize(context, 16),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                color: _isFocused
                    ? widget.borderColor ?? ColorConstants.primaryColor
                    : ColorConstants.textSecondaryColor,
                size: ResponsiveUtils.adaptiveSize(context, 20),
              )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: ColorConstants.textSecondaryColor,
                  size: ResponsiveUtils.adaptiveSize(context, 20),
                ),
                onPressed: _toggleObscureText,
              )
                  : widget.suffix,
              hintStyle: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
                color: widget.hintColor ?? ColorConstants.textHintColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
                ),
                borderSide: BorderSide(
                  color: widget.borderColor ?? ColorConstants.primaryColor,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
                ),
                borderSide: const BorderSide(
                  color: ColorConstants.errorColor,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
                ),
                borderSide: const BorderSide(
                  color: ColorConstants.errorColor,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.adaptiveSize(context, widget.borderRadius),
                ),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}

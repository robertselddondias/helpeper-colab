import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final int maxRating;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<double>? onRatingChanged;
  final bool allowHalfRating;

  const RatingBar({
    Key? key,
    required this.rating,
    this.size = 24,
    this.maxRating = 5,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.allowHalfRating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final double position = index + 1;
        final bool isHalfStar = position - rating > 0 &&
            position - rating < 1 &&
            allowHalfRating;
        final bool isFullStar = position <= rating;

        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(position)
              : null,
          child: Icon(
            isFullStar
                ? Icons.star
                : isHalfStar
                ? Icons.star_half
                : Icons.star_border,
            size: ResponsiveUtils.adaptiveSize(context, size),
            color: isFullStar || isHalfStar
                ? activeColor ?? ColorConstants.starColor
                : inactiveColor ?? ColorConstants.disabledColor,
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:helpper/core/constants/color_constants.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(-_animation.value, 0),
              colors: const [
                ColorConstants.shimmerBaseColor,
                ColorConstants.shimmerHighlightColor,
                ColorConstants.shimmerBaseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

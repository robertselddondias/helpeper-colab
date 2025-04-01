import 'package:flutter/material.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;

  // Number of columns to show at different breakpoints
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;

  const AdaptiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding = EdgeInsets.zero,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount = 3,
    this.desktopCrossAxisCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.isMobile(context)
        ? mobileCrossAxisCount
        : ResponsiveUtils.isTablet(context)
        ? tabletCrossAxisCount
        : desktopCrossAxisCount;

    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/routes/app_routes.dart';

class AppBarWithBadge extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final double elevation;
  final Color? backgroundColor;
  final Widget? flexibleSpace;

  const AppBarWithBadge({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.elevation = 0,
    this.backgroundColor,
    this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> finalActions = [
      Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: onNotificationTap ?? () => Get.toNamed(AppRoutes.NOTIFICATIONS),
          ),
          if (notificationCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: ColorConstants.errorColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  notificationCount > 9 ? '9+' : notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    ];

    if (actions != null) {
      finalActions.addAll(actions!);
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Get.back(),
      )
          : null,
      actions: finalActions,
      flexibleSpace: flexibleSpace,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

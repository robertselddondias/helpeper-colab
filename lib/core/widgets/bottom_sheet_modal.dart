import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/utils/responsive_utils.dart';

class BottomSheetModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double? height;
  final bool showDragHandle;
  final bool showCloseButton;
  final bool isDismissible;

  const BottomSheetModal({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.height,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.isDismissible = true,
  }) : super(key: key);

  static Future<T?> show<T>({
    required String title,
    required Widget content,
    List<Widget>? actions,
    double? height,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isDismissible = true,
  }) {
    return Get.bottomSheet(
      BottomSheetModal(
        title: title,
        content: content,
        actions: actions,
        height: height,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        isDismissible: isDismissible,
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: safeAreaPadding),
      height: height ?? MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) ...[
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.adaptiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

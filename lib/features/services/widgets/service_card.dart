import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/widgets/badge_custom.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/modern_card.dart';
import 'package:helpper/core/widgets/rating_bar.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/routes/app_routes.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool showDescription;
  final bool showCategory;
  final bool isCompact;
  final bool showActionButton;
  final String? actionButtonLabel;
  final VoidCallback? onActionButtonPressed;
  final bool useHero;
  final String? heroTag;

  const ServiceCard({
    Key? key,
    required this.service,
    this.onTap,
    this.showDescription = true,
    this.showCategory = true,
    this.isCompact = false,
    this.showActionButton = true,
    this.actionButtonLabel,
    this.onActionButtonPressed,
    this.useHero = false,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate adaptive dimensions
    final cardWidth = isCompact
        ? ResponsiveUtils.adaptiveSize(context, 180)
        : double.infinity;
    final imageHeight = isCompact
        ? ResponsiveUtils.adaptiveSize(context, 120)
        : ResponsiveUtils.adaptiveSize(context, 150);
    final borderRadius = ResponsiveUtils.adaptiveSize(context, 12);

    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed(
        AppRoutes.SERVICE_DETAIL,
        arguments: service,
      ),
      child: ModernCard(
        hasShadow: true,
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlays
              Stack(
                children: [
                  // Service image with caching
                  if (service.images.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      child: useHero
                          ? Hero(
                        tag: heroTag ?? 'service-${service.id}',
                        child: _buildServiceImage(imageHeight),
                      )
                          : _buildServiceImage(imageHeight),
                    )
                  else
                    Container(
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: ColorConstants.shimmerBaseColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white,
                          size: isCompact ? 32 : 48,
                        ),
                      ),
                    ),

                  // Overlays like category badge, rating, etc.
                  if (showCategory)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: BadgeCustom(
                        label: service.category,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        textColor: Colors.white,
                        fontSize: 10,
                        padding: 4,
                      ),
                    ),

                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BadgeCustom(
                      label: '${service.rating.toStringAsFixed(1)} ★',
                      backgroundColor: ColorConstants.starColor.withOpacity(0.8),
                      textColor: Colors.white,
                      fontSize: 10,
                      padding: 4,
                    ),
                  ),
                ],
              ),

              // Content area
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.adaptiveSize(context, 12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service title
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.adaptiveFontSize(
                            context,
                            isCompact ? 14 : 16
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Space between title and description/price
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),

                    // Service description (optional)
                    if (showDescription)
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.adaptiveFontSize(context, 13),
                          color: ColorConstants.textSecondaryColor,
                        ),
                        maxLines: isCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Space before price
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),

                    // Price row
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'R\$ ${service.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.adaptiveFontSize(
                                      context,
                                      isCompact ? 13 : 15
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstants.primaryColor,
                                ),
                              ),
                              if (!isCompact)
                                TextSpan(
                                  text: ' / ${service.priceType}',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.adaptiveFontSize(context, 12),
                                    color: ColorConstants.textSecondaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Action button (optional)
                        if (showActionButton && !isCompact)
                          CustomButton(
                            label: actionButtonLabel ?? 'Contratar',
                            onPressed: onActionButtonPressed ?? () => Get.toNamed(
                              AppRoutes.SERVICE_DETAIL,
                              arguments: service,
                            ),
                            type: ButtonType.primary,
                            size: ButtonSize.small,
                            isFullWidth: false,
                          ),
                      ],
                    ),

                    // Provider info (optional)
                    if (!isCompact)
                      Padding(
                        padding: EdgeInsets.only(top: ResponsiveUtils.adaptiveSize(context, 8)),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: ColorConstants.primaryColor,
                              child: Text(
                                service.providerName!.isNotEmpty
                                    ? service.providerName![0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                service.providerName ?? '',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.adaptiveFontSize(context, 12),
                                  color: ColorConstants.textSecondaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(double height) {
    return CachedNetworkImage(
      imageUrl: service.images.first,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: ColorConstants.shimmerBaseColor,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: ColorConstants.shimmerBaseColor,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}

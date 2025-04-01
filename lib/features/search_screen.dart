import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/widgets/animated_list_item.dart';
import 'package:helpper/core/widgets/badge_custom.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_refresh_indicator.dart';
import 'package:helpper/core/widgets/empty_state.dart';
import 'package:helpper/core/widgets/enhanced_text_field.dart';
import 'package:helpper/core/widgets/modern_card.dart';
import 'package:helpper/core/widgets/skeleton_loading.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ServicesController _controller = Get.find<ServicesController>();
  final FocusNode _searchFocusNode = FocusNode();

  final RxList<ServiceModel> searchResults = <ServiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isSearching = false.obs;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for staggered animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    // Check if a category was passed as an argument
    if (Get.arguments != null && Get.arguments['category'] != null) {
      selectedCategory.value = Get.arguments['category'];
      _performSearch();
    }

    // Listen to search focus changes
    _searchFocusNode.addListener(() {
      isSearching.value = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _searchFocusNode.removeListener(() {});
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    try {
      isLoading.value = true;

      final String query = _searchController.text.trim();
      final String? category = selectedCategory.value.isEmpty ? null : selectedCategory.value;

      searchResults.value = await _controller.searchServices(query, category);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Erro na busca: $e');
    }
  }

  void _selectCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = category;
    }
    _performSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveUtils.getScreenWidth(context);
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: Obx(() => isSearching.value
            ? const SizedBox.shrink()
            : const Text('Buscar Serviços')
        ),
        elevation: 0,
        backgroundColor: ColorConstants.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorConstants.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await _performSearch();
        },
        child: Column(
          children: [
            // Search header with animation
            AnimatedListItem(
              index: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.adaptiveSize(context, 16),
                  vertical: ResponsiveUtils.adaptiveSize(context, 8),
                ),
                child: EnhancedTextField(
                  controller: _searchController,
                  hint: 'O que você está procurando?',
                  prefixIcon: Icons.search,
                  focusNode: _searchFocusNode,
                  fillColor: Colors.white,
                  borderRadius: 16,
                  suffix: IconButton(
                    icon: const Icon(Icons.clear, color: ColorConstants.textSecondaryColor),
                    onPressed: _clearSearch,
                  ),
                  onChanged: (value) {
                    // Real-time search
                    _performSearch();
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _performSearch(),
                ),
              ),
            ),

            // Category filters with horizontal scrolling
            AnimatedListItem(
              index: 1,
              child: _buildCategoryFilters(context),
            ),

            // Results area
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return _buildLoadingState(isWideScreen);
                }

                if (searchResults.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildSearchResults(isWideScreen);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    return Container(
      height: ResponsiveUtils.adaptiveSize(context, 50),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.adaptiveSize(context, 8),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.adaptiveSize(context, 16),
        ),
        itemCount: _controller.categories.length,
        itemBuilder: (context, index) {
          final category = _controller.categories[index];
          return Obx(() {
            final isSelected = selectedCategory.value == category;

            return Padding(
              padding: EdgeInsets.only(
                right: ResponsiveUtils.adaptiveSize(context, 8),
              ),
              child: BadgeCustom(
                label: category,
                backgroundColor: isSelected
                    ? ColorConstants.primaryColor.withOpacity(0.2)
                    : Colors.white,
                textColor: isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.textPrimaryColor,
                borderRadius: 16,
                icon: _getCategoryIcon(category),
                onTap: () => _selectCategory(category),
              ),
            );
          });
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'limpeza': return Icons.cleaning_services_outlined;
      case 'reformas': return Icons.home_repair_service_outlined;
      case 'beleza': return Icons.spa_outlined;
      case 'aulas': return Icons.school_outlined;
      case 'tecnologia': return Icons.computer_outlined;
      case 'saúde': return Icons.health_and_safety_outlined;
      case 'eventos': return Icons.celebration_outlined;
      case 'animais': return Icons.pets_outlined;
      case 'consertos': return Icons.build_outlined;
      case 'jardinagem': return Icons.yard_outlined;
      case 'delivery': return Icons.delivery_dining_outlined;
      case 'transporte': return Icons.local_shipping_outlined;
      default: return Icons.miscellaneous_services_outlined;
    }
  }

  Widget _buildLoadingState(bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: isWideScreen
          ? GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      )
          : ListView.separated(
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoading(
            width: double.infinity,
            height: 150,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          SkeletonLoading(
            width: 100,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 8),
          SkeletonLoading(
            width: double.infinity,
            height: 20,
            borderRadius: 4,
          ),
          const SizedBox(height: 8),
          SkeletonLoading(
            width: 120,
            height: 16,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      title: 'Nenhum serviço encontrado',
      description: 'Tente outros termos ou categorias para encontrar o que procura.',
      icon: Icons.search_off,
      iconSize: 64,
      buttonText: 'Limpar Filtros',
      onButtonPressed: () {
        selectedCategory.value = '';
        _searchController.clear();
        _performSearch();
      },
    );
  }

  Widget _buildSearchResults(bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: isWideScreen
          ? GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final service = searchResults[index];
          return AnimatedListItem(
            index: index + 2, // Offset for header animations
            child: _buildServiceCard(service),
          );
        },
      )
          : ListView.separated(
        itemCount: searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final service = searchResults[index];
          return AnimatedListItem(
            index: index + 2, // Offset for header animations
            child: _buildServiceCard(service),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.SERVICE_DETAIL,
        arguments: service,
      ),
      child: ModernCard(
        hasShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image with category badge
            Stack(
              children: [
                if (service.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service.images.first,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: ColorConstants.shimmerBaseColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: ColorConstants.shimmerBaseColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: BadgeCustom(
                    label: service.category,
                    backgroundColor: Colors.black.withOpacity(0.6),
                    textColor: Colors.white,
                    fontSize: 10,
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Service title
            Text(
              service.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Service description
            Text(
              service.description,
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Bottom row with price and provider info
            Row(
              children: [
                // Price
                BadgeCustom(
                  label: 'R\$ ${service.price.toStringAsFixed(2)}',
                  backgroundColor: ColorConstants.primaryColor.withOpacity(0.1),
                  textColor: ColorConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),

                const Spacer(),

                // Action button
                CustomButton(
                  label: 'Contratar',
                  onPressed: () => Get.toNamed(
                    AppRoutes.SERVICE_DETAIL,
                    arguments: service,
                  ),
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                  isFullWidth: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

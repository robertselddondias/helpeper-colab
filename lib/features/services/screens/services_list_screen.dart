import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/widgets/adaptive_grid.dart';
import 'package:helpper/core/widgets/empty_state.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> with SingleTickerProviderStateMixin {
  final ServicesController _controller = Get.find<ServicesController>();

  final RxList<ServiceModel> recommendedServices = <ServiceModel>[].obs;
  final RxList<ServiceModel> nearbyServices = <ServiceModel>[].obs;
  final RxList<Map<String, dynamic>> categoryServices = <Map<String, dynamic>>[].obs;

  final RxBool isLoadingRecommended = true.obs;
  final RxBool isLoadingNearby = true.obs;
  final RxBool isLoadingCategories = true.obs;

  late ScrollController _scrollController;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      await Future.wait([
        _loadRecommendedServices(),
        _loadNearbyServices(),
        _loadCategoryServices(),
      ]);
    } catch (e) {
      _handleLoadError(e);
    }
  }

  Future<void> _loadRecommendedServices() async {
    try {
      isLoadingRecommended.value = true;
      recommendedServices.value = await _controller.getRecommendedServices();
    } catch (e) {
      debugPrint('Erro ao carregar serviços recomendados: $e');
    } finally {
      isLoadingRecommended.value = false;
    }
  }

  Future<void> _loadNearbyServices() async {
    try {
      isLoadingNearby.value = true;
      nearbyServices.value = await _controller.getNearbyServices();
    } catch (e) {
      debugPrint('Erro ao carregar serviços próximos: $e');
    } finally {
      isLoadingNearby.value = false;
    }
  }

  Future<void> _loadCategoryServices() async {
    try {
      isLoadingCategories.value = true;
      categoryServices.clear();

      final categories = [
        'Limpeza', 'Reformas', 'Tecnologia',
        'Beleza', 'Aulas', 'Saúde',
        'Eventos', 'Animais'
      ];

      for (var category in categories) {
        final services = await _controller.getServicesByCategory(category);
        if (services.isNotEmpty) {
          categoryServices.add({
            'category': category,
            'services': services,
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar serviços por categoria: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void _handleLoadError(dynamic error) {
    Get.snackbar(
      'Erro',
      'Não foi possível carregar os serviços',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ColorConstants.errorColor,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildMainAppBar(innerBoxIsScrolled),
            _buildCategoryGridHeader(),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _loadServices,
          child: _buildServicesList(context),
        ),
      ),
    );
  }

  SliverAppBar _buildMainAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      backgroundColor: ColorConstants.primaryColor,
      expandedHeight: ResponsiveUtils.adaptiveSize(context, 120),
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Helpp',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.adaptiveFontSize(context, 18),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorConstants.primaryColor,
                ColorConstants.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Get.toNamed(AppRoutes.SEARCH),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildCategoryGridHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AdaptiveGrid(
          children: _controller.categories.map((category) {
            return _buildCategoryItem(category);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildServicesList(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Recommended Services
        _buildServicesSection(
          title: 'Recomendados para você',
          services: recommendedServices,
          isLoading: isLoadingRecommended,
        ),

        // Nearby Services
        _buildServicesSection(
          title: 'Perto de você',
          services: nearbyServices,
          isLoading: isLoadingNearby,
        ),

        // Category Services
        Obx(() {
          if (isLoadingCategories.value) {
            return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final category = categoryServices[index];
                return _buildCategorySection(
                    category['category'],
                    category['services']
                );
              },
              childCount: categoryServices.length,
            ),
          );
        }),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String category) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.CATEGORY_SERVICES,
        arguments: {'category': category},
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                _getCategoryIcon(category),
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildServicesSection({
    required String title,
    required RxList<ServiceModel> services,
    required RxBool isLoading,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(
                    AppRoutes.SEARCH,
                    arguments: {'title': title},
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          Obx(() {
            if (isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (services.isEmpty) {
              return EmptyState(
                icon: Icons.search_off_outlined,
                title: 'Nenhum serviço encontrado',
                description: 'Não há serviços disponíveis nesta categoria',
                buttonText: 'Atualizar',
                onButtonPressed: _loadServices,
              );
            }

            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ServiceModel> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.CATEGORY_SERVICES,
                  arguments: {'category': category},
                ),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(service);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.SERVICE_DETAIL,
        arguments: service,
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: service.images.isNotEmpty
                    ? service.images.first
                    : 'https://via.placeholder.com/200x120',
                width: 200,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: ColorConstants.shimmerBaseColor,
                ),
                errorWidget: (context, url, error) => Container(
                  color: ColorConstants.shimmerBaseColor,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'R\$ ${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                      Text(
                        ' / ${service.priceType}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: ColorConstants.starColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'limpeza':
        return Icons.cleaning_services_outlined;
      case 'reformas':
        return Icons.home_repair_service_outlined;
      case 'beleza':
        return Icons.spa_outlined;
      case 'aulas':
        return Icons.school_outlined;
      case 'tecnologia':
        return Icons.computer_outlined;
      case 'saúde':
        return Icons.health_and_safety_outlined;
      case 'eventos':
        return Icons.celebration_outlined;
      case 'animais':
        return Icons.pets_outlined;
      case 'consertos':
        return Icons.build_outlined;
      case 'jardinagem':
        return Icons.yard_outlined;
      case 'delivery':
        return Icons.delivery_dining_outlined;
      case 'transporte':
        return Icons.local_shipping_outlined;
      default:
        return Icons.miscellaneous_services_outlined;
    }
  }
}

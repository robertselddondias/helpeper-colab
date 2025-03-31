import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final ServicesController _controller = Get.find<ServicesController>();

  final RxList<ServiceModel> recommendedServices = <ServiceModel>[].obs;
  final RxList<ServiceModel> nearbyServices = <ServiceModel>[].obs;
  final RxList<Map<String, dynamic>> categoryServices = <Map<String, dynamic>>[].obs;

  final RxBool isLoadingRecommended = true.obs;
  final RxBool isLoadingNearby = true.obs;
  final RxBool isLoadingCategories = true.obs;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    _loadRecommendedServices();
    _loadNearbyServices();
    _loadCategoryServices();
  }

  Future<void> _loadRecommendedServices() async {
    try {
      isLoadingRecommended.value = true;
      recommendedServices.value = await _controller.getRecommendedServices();
      isLoadingRecommended.value = false;
    } catch (e) {
      isLoadingRecommended.value = false;
      debugPrint('Erro ao carregar serviços recomendados: $e');
    }
  }

  Future<void> _loadNearbyServices() async {
    try {
      isLoadingNearby.value = true;
      nearbyServices.value = await _controller.getNearbyServices();
      isLoadingNearby.value = false;
    } catch (e) {
      isLoadingNearby.value = false;
      debugPrint('Erro ao carregar serviços próximos: $e');
    }
  }

  Future<void> _loadCategoryServices() async {
    try {
      isLoadingCategories.value = true;

      final categories = [
        'Limpeza',
        'Reformas',
        'Tecnologia',
        'Beleza',
        'Aulas',
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

      isLoadingCategories.value = false;
    } catch (e) {
      isLoadingCategories.value = false;
      debugPrint('Erro ao carregar serviços por categoria: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: ColorConstants.primaryColor,
              expandedHeight: 120,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Helpp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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
            ),
            // Fixed-height content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Use min size to prevent expansion
                  children: [
                    _buildCategoryGrid(),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Recomendados para você',
                      isLoadingRecommended.value,
                      recommendedServices,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Perto de você',
                      isLoadingNearby.value,
                      nearbyServices,
                    ),
                  ],
                ),
              ),
            ),
            // Dynamic content using SliverList instead of SliverToBoxAdapter with ListView
            Obx(() {
              if (isLoadingCategories.value) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = categoryServices[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: _buildCategorySection(
                        category['category'],
                        category['services'],
                      ),
                    );
                  },
                  childCount: categoryServices.length,
                ),
              );
            }),
            // Add bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _controller.categories.length,
      itemBuilder: (context, index) {
        final category = _controller.categories[index];
        return _buildCategoryItem(category);
      },
    );
  }

  Widget _buildCategoryItem(String category) {
    // Caminho para o ícone SVG da categoria
    IconData iconData = _getCategoryIcon(category);

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
                iconData,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Limpeza':
        return Icons.cleaning_services_outlined;
      case 'Reformas':
        return Icons.home_repair_service_outlined;
      case 'Beleza':
        return Icons.spa_outlined;
      case 'Aulas':
        return Icons.school_outlined;
      case 'Tecnologia':
        return Icons.computer_outlined;
      case 'Saúde':
        return Icons.health_and_safety_outlined;
      case 'Eventos':
        return Icons.celebration_outlined;
      case 'Animais':
        return Icons.pets_outlined;
      case 'Consertos':
        return Icons.build_outlined;
      case 'Jardinagem':
        return Icons.yard_outlined;
      case 'Delivery':
        return Icons.delivery_dining_outlined;
      case 'Transporte':
        return Icons.local_shipping_outlined;
      default:
        return Icons.miscellaneous_services_outlined;
    }
  }

  Widget _buildSection(
      String title,
      bool isLoading,
      List<ServiceModel> services,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (services.isEmpty)
        // Use a fixed height container for empty state to avoid layout jumps
          Container(
            height: 150,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important: Prevent column from taking unlimited height
                children: [
                  SvgPicture.asset(
                    'assets/images/empty-services.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nenhum serviço encontrado',
                    style: TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
        // Use a fixed height container for the horizontal list
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
                  width: 200,
                  height: 120,
                  color: ColorConstants.shimmerBaseColor,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 120,
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

  Widget _buildCategorySection(
      String category,
      List<ServiceModel> services,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Use min size to prevent expansion
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
            padding: EdgeInsets.zero, // Remove padding to save space
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(service);
            },
          ),
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  width: 200,
                  height: 120,
                  color: ColorConstants.shimmerBaseColor,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 120,
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
}

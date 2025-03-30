import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({Key? key}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServicesController _controller = Get.find<ServicesController>();
  final AuthController _authController = Get.find<AuthController>();

  late ServiceModel service;
  final RxBool isLoading = false.obs;
  final RxInt currentImageIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    service = Get.arguments as ServiceModel;
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    try {
      isLoading.value = true;

      final updatedService = await _controller.getServiceDetails(service.id);

      if (updatedService != null) {
        service = updatedService;
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Erro ao carregar detalhes do serviço: $e');
    }
  }

  bool get isOwnService {
    return _authController.firebaseUser.value?.uid == service.providerId;
  }

  void _requestService() {
    if (_authController.firebaseUser.value == null) {
      Get.toNamed(AppRoutes.LOGIN);
      return;
    }

    Get.toNamed(
      AppRoutes.REQUEST_SERVICE,
      arguments: service,
    );
  }

  void _editService() {
    Get.toNamed(
      AppRoutes.ADD_SERVICE,
      arguments: service,
    );
  }

  void _contactProvider() {
    if (_authController.firebaseUser.value == null) {
      Get.toNamed(AppRoutes.LOGIN);
      return;
    }

    Get.toNamed(
      AppRoutes.CHAT_DETAIL,
      arguments: {
        'userId': service.providerId,
        'userName': service.providerName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(),
                  _buildServiceInfo(),
                  _buildProviderInfo(),
                  _buildServiceDescription(),
                  _buildLocationInfo(),
                  _buildReviews(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      }),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: ColorConstants.textPrimaryColor,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.share_outlined,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
          onPressed: () {
            // Implementar compartilhamento
          },
        ),
        if (isOwnService)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
            onPressed: _editService,
          ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            itemCount: service.images.length,
            onPageChanged: (index) {
              currentImageIndex.value = index;
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: service.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: ColorConstants.shimmerBaseColor,
                ),
                errorWidget: (context, url, error) => Container(
                  color: ColorConstants.shimmerBaseColor,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              service.images.length,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentImageIndex.value == index
                      ? ColorConstants.primaryColor
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  service.category,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: service.isActive
                      ? ColorConstants.successColor.withOpacity(0.1)
                      : ColorConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  service.isActive ? 'Disponível' : 'Indisponível',
                  style: TextStyle(
                    fontSize: 14,
                    color: service.isActive
                        ? ColorConstants.successColor
                        : ColorConstants.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'R\$ ${service.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
              ),
              Text(
                ' / ${service.priceType}',
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 20,
                    color: ColorConstants.starColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${service.ratingCount})',
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: ColorConstants.primaryColor,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.providerName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: ColorConstants.primaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verificado',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isOwnService)
            IconButton(
              onPressed: _contactProvider,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_outlined,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Descrição',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.description,
            style: const TextStyle(
              fontSize: 14,
              color: ColorConstants.textSecondaryColor,
              height: 1.5,
            ),
          ),
          if (service.subCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Especialidades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: service.subCategories.map((subCategory) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConstants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subCategory,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConstants.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    if (service.address == null || service.address!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
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
          const Text(
            'Localização',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: ColorConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.address!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: ColorConstants.inputFillColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.map_outlined,
                color: ColorConstants.primaryColor,
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Avaliações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.REVIEWS,
                  arguments: service,
                ),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (service.ratingCount == 0)
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.star_border,
                    size: 48,
                    color: ColorConstants.textSecondaryColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ainda não há avaliações',
                    style: TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorConstants.starColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.starColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingBar(5, 0.8),
                          _buildRatingBar(4, 0.15),
                          _buildRatingBar(3, 0.04),
                          _buildRatingBar(2, 0.01),
                          _buildRatingBar(1, 0.0),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewItem(
                  'Maria Silva',
                  5.0,
                  'Excelente serviço! Muito profissional e pontual. Recomendo a todos.',
                  '2 dias atrás',
                ),
                const Divider(height: 32),
                _buildReviewItem(
                  'João Santos',
                  4.0,
                  'Bom trabalho, apenas um pouco de atraso na chegada. De resto, muito bom!',
                  '1 semana atrás',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.star,
            size: 12,
            color: ColorConstants.starColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorConstants.disabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: ColorConstants.starColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
      String name,
      double rating,
      String comment,
      String time,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: ColorConstants.primaryColor,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        rating.toInt(),
                            (index) => const Icon(
                          Icons.star,
                          size: 16,
                          color: ColorConstants.starColor,
                        ),
                      ),
                      ...List.generate(
                        5 - rating.toInt(),
                            (index) => const Icon(
                          Icons.star_border,
                          size: 16,
                          color: ColorConstants.starColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.textSecondaryColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: isOwnService
          ? Row(
        children: [
          CustomButton(
            label: 'Editar',
            onPressed: _editService,
            type: ButtonType.outline,
            icon: Icons.edit_outlined,
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: CustomButton(
              label: 'Contratar',
              onPressed: service.isActive ? _requestService : () {},
              icon: Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 16),
          CustomButton(
            label: 'Contato',
            onPressed: _contactProvider,
            type: ButtonType.outline,
            icon: Icons.chat_outlined,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}

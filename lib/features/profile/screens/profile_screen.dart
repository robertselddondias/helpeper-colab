import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/profile/profile_controller.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:helpper/data/models/service_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.userModel.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: ColorConstants.primaryColor.withOpacity(0.1),
                          child: user.photoUrl != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.person, size: 50),
                            ),
                          )
                              : Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => controller.pickProfileImage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (user.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Verificado',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (user.rating != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConstants.starColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: ColorConstants.starColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: ColorConstants.textPrimaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Editar Perfil',
                      onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                      type: ButtonType.outline,
                      size: ButtonSize.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (user.isProvider) ...[
                _buildSection(
                  context,
                  'Estatísticas',
                  [
                    _buildStatItem(
                      context,
                      Icons.home_repair_service_outlined,
                      'Serviços',
                      '${controller.servicesCount.value}',
                      ColorConstants.primaryColor,
                    ),
                    _buildStatItem(
                      context,
                      Icons.done_all_outlined,
                      'Serviços Realizados',
                      '${user.completedJobs}',
                      ColorConstants.successColor,
                    ),
                    _buildStatItem(
                      context,
                      Icons.star_outline,
                      'Avaliações',
                      '${controller.reviewsCount.value}',
                      ColorConstants.starColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Minhas habilidades',
                  [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.skills.isEmpty
                          ? [
                        _buildSkillItem(
                          context,
                          'Adicione suas habilidades',
                          isPlaceholder: true,
                        ),
                      ]
                          : user.skills
                          .map((skill) => _buildSkillItem(context, skill))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar habilidades'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Meus serviços',
                  [
                    Obx(() {
                      if (controller.isLoadingServices.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.services.isEmpty) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Image.asset(
                              'assets/images/empty_services.png',
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Você ainda não tem serviços',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Adicione seus primeiros serviços para começar a receber solicitações',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorConstants.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              label: 'Adicionar Serviço',
                              onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
                              icon: Icons.add,
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.services.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final service = controller.services[index];
                              return _buildServiceItem(context, service);
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            label: 'Adicionar Serviço',
                            onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
                            icon: Icons.add,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ] else ...[
                _buildSection(
                  context,
                  'Estatísticas',
                  [
                    _buildStatItem(
                      context,
                      Icons.home_repair_service_outlined,
                      'Serviços Contratados',
                      '${controller.hiredServicesCount.value}',
                      ColorConstants.primaryColor,
                    ),
                    _buildStatItem(
                      context,
                      Icons.done_all_outlined,
                      'Serviços Concluídos',
                      '${controller.completedRequestsCount.value}',
                      ColorConstants.successColor,
                    ),
                    _buildStatItem(
                      context,
                      Icons.star_outline,
                      'Avaliações Dadas',
                      '${controller.givenReviewsCount.value}',
                      ColorConstants.starColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Serviços que você pode precisar',
                  [
                    CustomButton(
                      label: 'Procurar Serviços',
                      onPressed: () => Get.toNamed(AppRoutes.HOME),
                      icon: Icons.search,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      List<Widget> children,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillItem(
      BuildContext context,
      String skill, {
        bool isPlaceholder = false,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isPlaceholder
            ? ColorConstants.disabledColor
            : ColorConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isPlaceholder
            ? null
            : Border.all(
          color: ColorConstants.primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: isPlaceholder
              ? ColorConstants.textSecondaryColor
              : ColorConstants.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context,
      ServiceModel service,
      ) {
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.SERVICE_DETAIL,
        arguments: service,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorConstants.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: service.images.first,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: ColorConstants.shimmerBaseColor,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: ColorConstants.inputFillColor,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: service.isActive
                              ? ColorConstants.successColor.withOpacity(0.1)
                              : ColorConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.isActive ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            fontSize: 12,
                            color: service.isActive
                                ? ColorConstants.successColor
                                : ColorConstants.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'R\$ ${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                      Text(
                        ' / ${service.priceType}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                      const Spacer(),
                      if (service.rating > 0) ...[
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: ColorConstants.starColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.textPrimaryColor,
                          ),
                        ),
                        Text(
                          ' (${service.ratingCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColorConstants.textSecondaryColor,
                          ),
                        ),
                      ],
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

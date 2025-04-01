import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/profile/profile_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final AuthController authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: Obx(() {
        final user = authController.userModel.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: ColorConstants.primaryColor,
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Sliver App Bar com perfil expandido
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: ColorConstants.primaryColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
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
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar com badge de verificação
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Avatar circular com borda
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Hero(
                                tag: 'profile-avatar',
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: user.photoUrl != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      imageUrl: user.photoUrl!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      placeholder: (context, url) => Container(
                                        color: Colors.white.withOpacity(0.2),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.white.withOpacity(0.2),
                                        child: const Icon(Icons.person,
                                            size: 50,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  )
                                      : Text(
                                    user.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Botão para editar foto
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => controller.pickProfileImage(),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: ColorConstants.accentColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),

                            // Badge de verificação
                            if (user.isVerified)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_rounded,
                                    color: ColorConstants.successColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Nome do usuário
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Rating e status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (user.rating != null) ...[
                              const Icon(
                                Icons.star_rounded,
                                color: ColorConstants.starColor,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Status de provedor
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.isProvider
                                    ? ColorConstants.accentColor.withOpacity(0.8)
                                    : Colors.grey.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.isProvider ? 'Prestador' : 'Cliente',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
                ),
              ],
            ),

            // Conteúdo principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ações do perfil
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Editar Perfil',
                            onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                            type: ButtonType.outline,
                            size: ButtonSize.small,
                            icon: Icons.edit_outlined,
                          ),
                        ),
                        if (user.isProvider) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Meus Ganhos',
                              onPressed: () => Get.toNamed(AppRoutes.EARNINGS),
                              type: ButtonType.outline,
                              size: ButtonSize.small,
                              icon: Icons.payments_outlined,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Estatísticas - Layout adaptativo baseado no tamanho da tela
                    _buildStatisticsSection(user, controller, screenWidth),

                    const SizedBox(height: 24),

                    // Caso seja prestador, exibe habilidades
                    if (user.isProvider)
                      _buildSkillsSection(user, controller),

                    const SizedBox(height: 24),

                    // Meus serviços ou serviços que já contratou
                    _buildServicesSection(user, controller),

                    const SizedBox(height: 80), // Espaço para bottom navigation bar
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Widget para a seção de estatísticas
  Widget _buildStatisticsSection(dynamic user, ProfileController controller, double screenWidth) {
    // Layout adaptativo - grade ou uma coluna, dependendo do tamanho da tela
    final isWideScreen = screenWidth > 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (isWideScreen)
        // Layout em grade para telas maiores
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: _buildStatItems(user, controller),
          )
        else
        // Layout em coluna para telas menores
          Column(
            children: _buildStatItems(user, controller).map((widget) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget,
              );
            }).toList(),
          ),
      ],
    );
  }

  // Lista de widgets para os itens de estatísticas
  List<Widget> _buildStatItems(dynamic user, ProfileController controller) {
    final isProvider = user.isProvider;

    return [
      _buildStatCard(
        icon: Icons.home_repair_service_rounded,
        title: isProvider ? 'Serviços' : 'Serviços Contratados',
        value: isProvider
            ? '${controller.servicesCount.value}'
            : '${controller.hiredServicesCount.value}',
        color: ColorConstants.primaryColor,
      ),
      _buildStatCard(
        icon: Icons.done_all_rounded,
        title: isProvider ? 'Serviços Realizados' : 'Serviços Concluídos',
        value: isProvider
            ? '${user.completedJobs}'
            : '${controller.completedRequestsCount.value}',
        color: ColorConstants.successColor,
      ),
      _buildStatCard(
        icon: Icons.star_rounded,
        title: isProvider ? 'Avaliações' : 'Avaliações Dadas',
        value: isProvider
            ? '${controller.reviewsCount.value}'
            : '${controller.givenReviewsCount.value}',
        color: ColorConstants.starColor,
      ),
      if (isProvider)
        _buildStatCard(
          icon: Icons.monetization_on_rounded,
          title: 'Ganhos',
          value: 'Ver',
          color: ColorConstants.accentColor,
          onTap: () => Get.toNamed(AppRoutes.EARNINGS),
        )
      else
        _buildStatCard(
          icon: Icons.favorite_rounded,
          title: 'Favoritos',
          value: '0',
          color: Colors.red,
        ),
    ];
  }

  // Widget para um card de estatística individual
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onTap != null ? color : ColorConstants.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color,
              ),
          ],
        ),
      ),
    );
  }

  // Widget para a seção de habilidades
  Widget _buildSkillsSection(dynamic user, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Minhas habilidades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
              icon: const Icon(
                Icons.add_circle_outline,
                size: 18,
              ),
              label: const Text('Adicionar'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: user.skills.isEmpty
              ? const Center(
            child: Text(
              'Adicione suas habilidades para que os clientes possam encontrá-lo mais facilmente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorConstants.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          )
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills.map<Widget>((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorConstants.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: ColorConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget para a seção de serviços
  Widget _buildServicesSection(dynamic user, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              user.isProvider ? 'Meus serviços' : 'Últimas contratações',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.isProvider)
              TextButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 18,
                ),
                label: const Text('Adicionar'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (user.isProvider)
          Obx(() {
            if (controller.isLoadingServices.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.services.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_repair_service_outlined,
                        size: 48,
                        color: ColorConstants.textSecondaryColor.withOpacity(0.5),
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
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.services.length > 3 ? 3 : controller.services.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final service = controller.services[index];
                return _buildServiceCard(service, controller);
              },
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_outlined,
                    size: 48,
                    color: ColorConstants.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explore serviços',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Encontre prestadores de serviço qualificados próximos a você',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Procurar Serviços',
                    onPressed: () => Get.offNamed(AppRoutes.HOME),
                    icon: Icons.search,
                  ),
                ],
              ),
            ),
          ),

        // Mostrar mais serviços
        if (user.isProvider && controller.services.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  // Navegar para uma tela que mostre todos os serviços
                },
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Ver todos os serviços'),
              ),
            ),
          ),
      ],
    );
  }

  // Widget para card de serviço
  Widget _buildServiceCard(ServiceModel service, ProfileController controller) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.SERVICE_DETAIL,
        arguments: service,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do serviço
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: service.images.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: service.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
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
                    )
                        : Container(
                      color: ColorConstants.shimmerBaseColor,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                  // Badge de status (ativo/inativo)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: service.isActive
                            ? ColorConstants.successColor
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.isActive ? 'Ativo' : 'Inativo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Informações do serviço
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Categoria
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
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: ColorConstants.starColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Título
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
                    // Preço
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
                        // Botão de toggle ativo/inativo
                        GestureDetector(
                          onTap: () => controller.toggleServiceStatus(
                              service.id,
                              service.isActive
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: service.isActive
                                  ? ColorConstants.successColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: service.isActive
                                    ? ColorConstants.successColor
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  service.isActive
                                      ? Icons.toggle_on_rounded
                                      : Icons.toggle_off_rounded,
                                  size: 16,
                                  color: service.isActive
                                      ? ColorConstants.successColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  service.isActive ? 'Ativo' : 'Inativo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: service.isActive
                                        ? ColorConstants.successColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

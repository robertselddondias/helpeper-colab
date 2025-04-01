import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({Key? key}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> with SingleTickerProviderStateMixin {
  final ServicesController _controller = Get.find<ServicesController>();
  final AuthController _authController = Get.find<AuthController>();

  // Controller para a galeria de imagens
  final PageController _imagePageController = PageController();

  // Controller para tabs
  late TabController _tabController;

  late ServiceModel service;
  final RxBool isLoading = false.obs;
  final RxInt currentImageIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    service = Get.arguments as ServiceModel;
    _loadServiceDetails();

    // Inicializa o controller de tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    super.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculando alturas responsivas
    final imageHeight = screenHeight * 0.35;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // AppBar com imagem de fundo expandida
              SliverAppBar(
                expandedHeight: imageHeight,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Stack(
                  children: [
                    // Galeria de imagens
                    PageView.builder(
                      controller: _imagePageController,
                      itemCount: service.images.isEmpty ? 1 : service.images.length,
                      onPageChanged: (index) {
                        currentImageIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        return service.images.isEmpty
                            ? Container(
                          color: ColorConstants.shimmerBaseColor,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        )
                            : CachedNetworkImage(
                          imageUrl: service.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: imageHeight,
                          placeholder: (context, url) => Container(
                            color: ColorConstants.shimmerBaseColor,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: ColorConstants.shimmerBaseColor,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Indicador de página
                    if (service.images.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _imagePageController,
                            count: service.images.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: ColorConstants.primaryColor,
                              dotColor: Colors.white.withOpacity(0.5),
                              dotHeight: 8,
                              dotWidth: 8,
                              expansionFactor: 4,
                            ),
                          ),
                        ),
                      ),

                    // Overlay gradiente para os botões
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                leading: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                actions: [
                  // Botão de compartilhar
                  GestureDetector(
                    onTap: () {
                      // Implementar compartilhamento
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16, top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Botão de editar (apenas para serviços próprios)
                  if (isOwnService)
                    GestureDetector(
                      onTap: _editService,
                      child: Container(
                        margin: const EdgeInsets.only(right: 16, top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ];
          },
          body: Column(
            children: [
              // Header com informações do serviço
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Categoria
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(service.category),
                                color: ColorConstants.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.category,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Badge de disponibilidade
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: service.isActive
                                ? ColorConstants.successColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                service.isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: service.isActive
                                    ? ColorConstants.successColor
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.isActive ? 'Disponível' : 'Indisponível',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: service.isActive
                                      ? ColorConstants.successColor
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Título
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Preço e avaliação
                    Row(
                      children: [
                        // Preço
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.paid_rounded,
                                color: ColorConstants.accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'R\$ ${service.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ColorConstants.accentColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ${service.priceType}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ColorConstants.textSecondaryColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Avaliação
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
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
              ),

              // Tabs de navegação
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: ColorConstants.primaryColor,
                  unselectedLabelColor: ColorConstants.textSecondaryColor,
                  indicatorColor: ColorConstants.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Detalhes'),
                    Tab(text: 'Avaliações'),
                    Tab(text: 'Prestador'),
                  ],
                ),
              ),

              // Divisor sutil
              const Divider(height: 1),

              // Conteúdo das tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab de detalhes
                    _buildDetailsTab(context),

                    // Tab de avaliações
                    _buildReviewsTab(context),

                    // Tab de prestador
                    _buildProviderTab(context),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      // Barra inferior fixa com botões de ação
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: isOwnService
              ? Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Editar',
                  onPressed: _editService,
                  type: ButtonType.outline,
                  icon: Icons.edit_rounded,
                ),
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomButton(
                  label: 'Contratar',
                  onPressed: service.isActive ? () => _requestService() : () {},
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: CustomButton(
                  label: 'Contatar',
                  onPressed: _contactProvider,
                  type: ButtonType.outline,
                  icon: Icons.chat_bubble_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab de detalhes do serviço
  Widget _buildDetailsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Descrição
        _buildSectionCard(
          title: 'Descrição',
          icon: Icons.description_outlined,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: ColorConstants.textPrimaryColor,
                ),
              ),

              // Especialidades/Subcategorias
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
                          fontSize: 13,
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
        ),

        const SizedBox(height: 16),

        // Localização
        if (service.address != null && service.address!.isNotEmpty)
          _buildSectionCard(
            title: 'Localização',
            icon: Icons.location_on_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: ColorConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        service.address!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: ColorConstants.inputFillColor,
                    child: const Center(
                      child: Icon(
                        Icons.map_outlined,
                        color: ColorConstants.primaryColor,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Tab de avaliações
  Widget _buildReviewsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumo das avaliações
        _buildSectionCard(
          title: 'Resumo',
          icon: Icons.star_outline_rounded,
          content: Column(
            children: [
              Row(
                children: [
                  // Nota média
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorConstants.starColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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
                  // Barras de avaliação
                  Expanded(
                    child: Column(
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
              Text(
                '${service.ratingCount} avaliações',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),

              // Botão para ver todas
              if (service.ratingCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomButton(
                    label: 'Ver todas as avaliações',
                    onPressed: () => Get.toNamed(
                      AppRoutes.REVIEWS,
                      arguments: service,
                    ),
                    type: ButtonType.outline,
                    size: ButtonSize.small,
                    icon: Icons.arrow_forward_rounded,
                    iconAfterText: true,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de avaliações recentes
        if (service.ratingCount > 0)
          _buildSectionCard(
            title: 'Avaliações recentes',
            icon: Icons.comment_outlined,
            content: Column(
              children: [
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
          )
        else
        // Estado vazio
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
                    Icons.star_border_rounded,
                    size: 48,
                    color: ColorConstants.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ainda não há avaliações',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seja o primeiro a avaliar este serviço',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Tab do prestador de serviço
  Widget _buildProviderTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card do prestador
        _buildSectionCard(
          title: 'Prestador',
          icon: Icons.person_outline_rounded,
          content: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: ColorConstants.primaryColor,
                child: Text(
                  service.providerName?.substring(0, 1).toUpperCase() ?? 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.providerName ?? 'Prestador',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: ColorConstants.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Responde em até 1h',
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
              // Botão de chat
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
                      Icons.chat_bubble_outline_rounded,
                      color: ColorConstants.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Estatísticas do prestador
        _buildSectionCard(
          title: 'Estatísticas',
          icon: Icons.insert_chart_outlined_rounded,
          content: Column(
            children: [
              _buildStatItem(
                icon: Icons.work_outline_rounded,
                title: 'Serviços realizados',
                value: '25',
                color: ColorConstants.primaryColor,
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                icon: Icons.star_outline_rounded,
                title: 'Avaliação média',
                value: service.rating.toStringAsFixed(1),
                color: ColorConstants.starColor,
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                icon: Icons.timer_outlined,
                title: 'Tempo de resposta',
                value: '1h',
                color: ColorConstants.infoColor,
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                icon: Icons.calendar_today_outlined,
                title: 'Na plataforma desde',
                value: 'Jan 2023',
                color: ColorConstants.textSecondaryColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Outros serviços do prestador
        _buildSectionCard(
          title: 'Outros serviços deste prestador',
          icon: Icons.home_repair_service_outlined,
          content: Column(
            children: [
              // Estado vazio ou lista real de serviços
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Este prestador ainda não tem outros serviços cadastrados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ),
              ),

              // Botão para ver todos
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CustomButton(
                  label: 'Ver perfil completo',
                  onPressed: () {
                    // Navegar para o perfil do prestador
                  },
                  type: ButtonType.outline,
                  size: ButtonSize.small,
                  icon: Icons.arrow_forward_rounded,
                  iconAfterText: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card de seção padrão
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da seção
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Linha divisória
          const Divider(height: 1),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  // Barra de avaliação
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
            Icons.star_rounded,
            size: 12,
            color: ColorConstants.starColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                // Barra de fundo
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorConstants.disabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Barra de progresso
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

  // Item de avaliação
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
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: ColorConstants.primaryColor,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                          Icons.star_rounded,
                          size: 16,
                          color: ColorConstants.starColor,
                        ),
                      ),
                      ...List.generate(
                        5 - rating.toInt(),
                            (index) => const Icon(
                          Icons.star_border_rounded,
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
        const SizedBox(height: 12),
        Text(
          comment,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: ColorConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  // Item de estatística do prestador
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.textSecondaryColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Ícone da categoria
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

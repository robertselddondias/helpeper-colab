import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/chat/screens/chats_list_screen.dart';
import 'package:helpper/features/profile/screens/profile_screen.dart';
import 'package:helpper/features/requests/screens/requests_screen.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final RxInt _currentIndex = 0.obs;

  final List<Widget> _screens = [
    const ServicesListScreen(),
    const RequestsScreen(),
    const ChatsListScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Serviços',
    'Solicitações',
    'Conversas',
    'Perfil',
  ];

  void _onItemTapped(int index) {
    _currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      // Define a cor da barra de status para corresponder ao AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // AppBar invisível só para definir cor da barra de status
        child: AppBar(
          backgroundColor: ColorConstants.primaryColor,
          elevation: 0,
          toolbarHeight: 0,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Obx(() => IndexedStack(
        index: _currentIndex.value,
        children: _screens,
      )),
      floatingActionButton: Obx(() {
        if (_currentIndex.value == 0 && _authController.userModel.value?.isProvider == true) {
          return FloatingActionButton(
            backgroundColor: ColorConstants.primaryColor,
            child: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
          );
        }
        return const SizedBox.shrink();
      }),
      bottomNavigationBar: Obx(() {
        final isTabletDevice = MediaQuery.of(context).size.width >= 600;
        return BottomNavigationBar(
          currentIndex: _currentIndex.value,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorConstants.primaryColor,
          unselectedItemColor: ColorConstants.textSecondaryColor,
          elevation: 8,
          selectedFontSize: isTabletDevice ? 14 : 12,
          unselectedFontSize: isTabletDevice ? 12 : 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Solicitações',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Conversas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        );
      }),
    );
  }
}

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

      categoryServices.clear();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        top: false, // Não aplica SafeArea na parte superior para permitir que o AppBar se estenda até a barra de status
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsividade baseada no tamanho da tela
            final isTablet = constraints.maxWidth >= 600;

            return RefreshIndicator(
              onRefresh: _loadServices,
              color: ColorConstants.primaryColor,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar aprimorada com estética original
                  SliverAppBar(
                    backgroundColor: ColorConstants.primaryColor,
                    expandedHeight: isTablet ? 150 : 130,
                    titleSpacing: 16,
                    pinned: true,
                    stretch: true,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(
                        left: 20,
                        bottom: 16,
                        right: 16,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Helpp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 26 : 20,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Encontre os melhores serviços aqui',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () => Get.toNamed(AppRoutes.SEARCH),
                        padding: const EdgeInsets.all(8),
                        iconSize: isTablet ? 28 : 24,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
                        padding: const EdgeInsets.all(8),
                        iconSize: isTablet ? 28 : 24,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),

                  // Conteúdo da página com padding adaptativo
                  SliverPadding(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // Grade de categorias responsiva
                          _buildCategoryGrid(isTablet),

                          SizedBox(height: isTablet ? 32.0 : 24.0),

                          // Seções de serviços responsivas
                          _buildServicesSection(
                            'Recomendados para você',
                            isLoadingRecommended.value,
                            recommendedServices,
                            isTablet,
                          ),

                          SizedBox(height: isTablet ? 32.0 : 24.0),

                          _buildServicesSection(
                            'Perto de você',
                            isLoadingNearby.value,
                            nearbyServices,
                            isTablet,
                          ),

                          // Seções por categoria
                          Obx(() {
                            if (isLoadingCategories.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (categoryServices.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: categoryServices.map((category) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 16.0 : 12.0,
                                  ),
                                  child: _buildServicesSection(
                                    category['category'],
                                    false,
                                    category['services'],
                                    isTablet,
                                  ),
                                );
                              }).toList(),
                            );
                          }),

                          // Espaço extra no final para evitar que o conteúdo fique atrás do FAB/navbar
                          SizedBox(height: isTablet ? 100.0 : 80.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Método modificado para construir a grade de categorias
  Widget _buildCategoryGrid(bool isTablet) {
    return SizedBox(
      height: isTablet ? 140 : 120,
      child: GridView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.2 : 1.0,
        ),
        itemCount: _controller.categories.length,
        itemBuilder: (context, index) {
          final category = _controller.categories[index];
          return _buildCategoryItem(category, isTablet);
        },
      ),
    );
  }

  // Método modificado para construir item de categoria
  Widget _buildCategoryItem(String category, bool isTablet) {
    // Caminho para o ícone SVG da categoria
    IconData iconData = _getCategoryIcon(category);

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.CATEGORY_SERVICES,
        arguments: {'category': category},
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 70 : 60,
            height: isTablet ? 70 : 60,
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(
              iconData,
              color: ColorConstants.primaryColor,
              size: isTablet ? 32 : 28,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: ColorConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Método aprimorado para construir seção de serviços
  Widget _buildServicesSection(
      String title,
      bool isLoading,
      List<ServiceModel> services,
      bool isTablet,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cabeçalho com linha decorativa
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => Get.toNamed(
                AppRoutes.SEARCH,
                arguments: {'title': title, 'category': title},
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: ColorConstants.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Conteúdo com tratamento de estados
        if (isLoading)
          Container(
            height: isTablet ? 250 : 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (services.isEmpty)
        // Estado vazio específico para cada seção
          Container(
            height: isTablet ? 180 : 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: isTablet ? 60 : 48,
                    color: ColorConstants.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  // Mensagem específica para recomendados e próximos
                  Text(
                    title == 'Recomendados para você' || title == 'Perto de você'
                        ? 'Nenhum serviço encontrado'
                        : 'Nenhum serviço disponível nesta categoria',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo com sugestão
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      title == 'Recomendados para você'
                          ? 'Explore mais categorias para encontrar serviços'
                          : title == 'Perto de você'
                          ? 'Não encontramos serviços próximos a você no momento'
                          : 'Tente explorar outras categorias',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: ColorConstants.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
        // Lista de serviços melhorada
          SizedBox(
            height: isTablet ? 270 : 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(service, isTablet);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service, bool isTablet) {
    final cardWidth = isTablet ? 250.0 : 200.0;
    final imageHeight = isTablet ? 150.0 : 120.0;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.SERVICE_DETAIL,
        arguments: service,
      ),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack para a imagem com badge de categoria
            Stack(
              children: [
                // Imagem do serviço
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: service.images.isNotEmpty
                      ? Image.network(
                    service.images.first,
                    width: cardWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: cardWidth,
                      height: imageHeight,
                      color: ColorConstants.shimmerBaseColor,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
                  )
                      : Container(
                    width: cardWidth,
                    height: imageHeight,
                    color: ColorConstants.shimmerBaseColor,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                ),
                // Badge de categoria flutuante
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      service.category,
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Informações do serviço
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            color: ColorConstants.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Rodapé com preço e avaliação
                    Row(
                      children: [
                        // Preço
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'R\$ ${service.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstants.primaryColor,
                                ),
                              ),
                              Text(
                                'por ${service.priceType}',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  color: ColorConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avaliação
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.starColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: ColorConstants.starColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                service.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.starColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

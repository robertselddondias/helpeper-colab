import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/profile/profile_controller.dart';
import 'package:helpper/features/requests/requests_controller.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final RequestsController _requestsController = Get.find<RequestsController>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // Update the selected tab in the controller
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _requestsController.selectedTab.value = 'pending';
            break;
          case 1:
            _requestsController.selectedTab.value = 'accepted';
            break;
          case 2:
            _requestsController.selectedTab.value = 'completed';
            break;
        }
      }
    });

    // Load data
    _profileController.loadProfileData();
    _profileController.fetchServices();
    _requestsController.loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await _profileController.loadProfileData();
          await _profileController.fetchServices();
          await _requestsController.loadRequests();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with greeting and profile
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: ColorConstants.primaryColor,
              expandedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
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
                  child: Obx(() {
                    final user = _authController.userModel.value;
                    if (user == null) {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Greeting and date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.name.split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stats summary in a row
                        Row(
                          children: [
                            _buildQuickStat(
                              'Requisições',
                              _requestsController.getFilteredRequests().length.toString(),
                              Icons.assignment_outlined,
                            ),
                            const SizedBox(width: 12),
                            _buildQuickStat(
                              'Serviços',
                              _profileController.servicesCount.toString(),
                              Icons.home_repair_service_outlined,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_outlined, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.CHATS),
                  tooltip: 'Mensagens',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
                  tooltip: 'Notificações',
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.PROFILE),
                  tooltip: 'Perfil',
                ),
              ],
            ),

            // Earnings overview card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildEarningsCard(),
              ),
            ),

            // Requests section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Solicitações de Serviço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Implement filtering options
                      },
                      tooltip: 'Filtrar',
                    ),
                  ],
                ),
              ),
            ),

            // Tabs for request status
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: ColorConstants.primaryColor,
                  unselectedLabelColor: ColorConstants.textSecondaryColor,
                  indicatorColor: ColorConstants.primaryColor,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Pendentes'),
                    Tab(text: 'Em andamento'),
                    Tab(text: 'Concluídas'),
                  ],
                ),
              ),
            ),

            // Request list based on tab
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestsList('pending'),
                  _buildRequestsList('accepted'),
                  _buildRequestsList('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
      // FAB to add new service
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstants.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
        tooltip: 'Adicionar Serviço',
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.EARNINGS),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorConstants.accentColor,
              ColorConstants.accentColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.accentColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                  'Ganhos do Mês',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final completedJobs = _authController.userModel.value?.completedJobs ?? 0;
              // Note: In a real implementation, this should come from a dedicated earnings controller
              final monthlyEarnings = 0.0; // Replace with actual earnings data

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(monthlyEarnings),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$completedJobs serviços realizados',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(String status) {
    return Obx(() {
      if (_requestsController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final requests = _requestsController.getFilteredRequests();

      if (requests.isEmpty) {
        return _buildEmptyState(status);
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final request = requests[index];
          return GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.REQUEST_DETAIL,
              arguments: request.id,
            ),
            child: Container(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorConstants.primaryColor,
                          radius: 20,
                          child: Text(
                            request.clientName[0].toUpperCase(),
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
                                request.clientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Solicitado em ${DateFormat('dd/MM/yyyy').format(request.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.serviceName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.description,
                          style: const TextStyle(
                            color: ColorConstants.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: ColorConstants.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(request.scheduledDate),
                                  style: const TextStyle(
                                    color: ColorConstants.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: ColorConstants.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  request.scheduledTime,
                                  style: const TextStyle(
                                    color: ColorConstants.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${request.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.primaryColor,
                              ),
                            ),
                            _buildStatusChip(request.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(String status) {
    String message;
    String subMessage;
    IconData icon;

    switch (status) {
      case 'pending':
        message = 'Nenhuma solicitação pendente';
        subMessage = 'Você não tem novas solicitações de serviço';
        icon = Icons.inbox_outlined;
        break;
      case 'accepted':
        message = 'Nenhuma solicitação em andamento';
        subMessage = 'Você não tem serviços em andamento';
        icon = Icons.engineering_outlined;
        break;
      case 'completed':
        message = 'Nenhuma solicitação concluída';
        subMessage = 'Você não tem serviços concluídos';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'Nenhuma solicitação encontrada';
        subMessage = 'Você não tem solicitações de serviço';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: ColorConstants.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: const TextStyle(
              color: ColorConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (status == 'pending')
            CustomButton(
              label: 'Adicionar Serviço',
              onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
              type: ButtonType.outline,
              icon: Icons.add,
              isFullWidth: false,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = ColorConstants.warningColor;
        label = 'Pendente';
        break;
      case 'accepted':
        color = ColorConstants.infoColor;
        label = 'Em andamento';
        break;
      case 'completed':
        color = ColorConstants.successColor;
        label = 'Concluído';
        break;
      case 'cancelled':
        color = ColorConstants.errorColor;
        label = 'Cancelado';
        break;
      default:
        color = ColorConstants.textSecondaryColor;
        label = status.capitalize ?? status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

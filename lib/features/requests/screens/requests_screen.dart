import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/loading_indicator.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/requests/requests_controller.dart';
import 'package:helpper/features/requests/widgets/request_card.dart';
import 'package:helpper/routes/app_routes.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  final RequestsController _controller = Get.find<RequestsController>();
  final AuthController _authController = Get.find<AuthController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Update the selected tab in the controller
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _controller.selectedTab.value = 'pending';
            break;
          case 1:
            _controller.selectedTab.value = 'accepted';
            break;
          case 2:
            _controller.selectedTab.value = 'completed';
            break;
          case 3:
            _controller.selectedTab.value = 'cancelled';
            break;
        }
      }
    });

    // Load requests on screen initialization
    _controller.loadRequests();
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
      appBar: AppBar(
        title: const Text('Solicitações'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorConstants.primaryColor,
          unselectedLabelColor: ColorConstants.textSecondaryColor,
          indicatorColor: ColorConstants.primaryColor,
          tabs: const [
            Tab(text: 'Pendentes'),
            Tab(text: 'Aceitas'),
            Tab(text: 'Concluídas'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: LoadingIndicator(),
          );
        }

        final requests = _controller.getFilteredRequests();

        if (requests.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = requests[index];
            return RequestCard(
              request: request,
              onTap: () => Get.toNamed(
                AppRoutes.REQUEST_DETAIL,
                arguments: request.id,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    final isProvider = _authController.userModel.value?.isProvider ?? false;
    String message;
    String subMessage;
    IconData icon;

    switch (_controller.selectedTab.value) {
      case 'pending':
        message = isProvider
            ? 'Nenhuma solicitação pendente'
            : 'Nenhuma solicitação pendente';
        subMessage = isProvider
            ? 'Você não tem novas solicitações de serviço'
            : 'Solicite um serviço para começar';
        icon = Icons.inbox_outlined;
        break;
      case 'accepted':
        message = 'Nenhuma solicitação em andamento';
        subMessage = isProvider
            ? 'Você não tem serviços em andamento'
            : 'Suas solicitações aceitas aparecerão aqui';
        icon = Icons.engineering_outlined;
        break;
      case 'completed':
        message = 'Nenhuma solicitação concluída';
        subMessage = isProvider
            ? 'Você não tem serviços concluídos'
            : 'Seus serviços concluídos aparecerão aqui';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'Nenhuma solicitação cancelada';
        subMessage = 'Solicitações canceladas aparecerão aqui';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'Nenhuma solicitação encontrada';
        subMessage = isProvider
            ? 'Você não tem solicitações de serviço'
            : 'Solicite um serviço para começar';
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
          if (!isProvider && _controller.selectedTab.value == 'pending')
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.SERVICES),
              icon: const Icon(Icons.search),
              label: const Text('Procurar Serviços'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/loading_indicator.dart';
import 'package:helpper/data/models/request_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/requests/requests_controller.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:intl/intl.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({Key? key}) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final RequestsController _controller = Get.find<RequestsController>();
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _cancellationReasonController = TextEditingController();

  late String requestId;

  @override
  void initState() {
    super.initState();
    requestId = Get.arguments as String;
    _controller.loadRequestDetail(requestId);
  }

  @override
  void dispose() {
    _cancellationReasonController.dispose();
    super.dispose();
  }

  void _showCancellationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancelar Solicitação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Por favor, informe o motivo do cancelamento:',
              style: TextStyle(
                color: ColorConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cancellationReasonController,
              decoration: const InputDecoration(
                hintText: 'Motivo do cancelamento',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final reason = _cancellationReasonController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar(
                  'Erro',
                  'Por favor, informe o motivo do cancelamento',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              _controller.cancelRequest(requestId, reason);
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: ColorConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _updateRequestStatus(String status) {
    Get.dialog(
      AlertDialog(
        title: Text(_getStatusUpdateTitle(status)),
        content: Text(_getStatusUpdateMessage(status)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.updateRequestStatus(requestId, status);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _getStatusUpdateTitle(String status) {
    switch (status) {
      case 'accepted':
        return 'Aceitar Solicitação';
      case 'completed':
        return 'Concluir Serviço';
      default:
        return 'Atualizar Status';
    }
  }

  String _getStatusUpdateMessage(String status) {
    switch (status) {
      case 'accepted':
        return 'Deseja aceitar esta solicitação de serviço?';
      case 'completed':
        return 'Deseja marcar este serviço como concluído?';
      default:
        return 'Deseja atualizar o status desta solicitação?';
    }
  }

  void _contactUser() {
    final request = _controller.currentRequest.value;
    if (request == null) return;

    final isProvider = _authController.userModel.value?.isProvider ?? false;
    final userId = isProvider ? request.clientId : request.providerId;
    final userName = isProvider ? request.clientName : request.providerName;

    Get.toNamed(
      AppRoutes.CHAT_DETAIL,
      arguments: {
        'userId': userId,
        'userName': userName,
      },
    );
  }

  void _addReview() {
    final request = _controller.currentRequest.value;
    if (request == null) return;

    Get.toNamed(
      AppRoutes.ADD_REVIEW,
      arguments: request,
    );
  }

  void _makePayment() {
    Get.dialog(
      AlertDialog(
        title: const Text('Realizar Pagamento'),
        content: const Text(
          'Deseja efetuar o pagamento deste serviço agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.createTransaction(requestId);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingDetail.value) {
          return const Center(
            child: LoadingIndicator(),
          );
        }

        final request = _controller.currentRequest.value;
        if (request == null) {
          return const Center(
            child: Text('Solicitação não encontrada'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusSection(request),
              const SizedBox(height: 16),
              _buildServiceSection(request),
              const SizedBox(height: 16),
              _buildScheduleSection(request),
              const SizedBox(height: 16),
              _buildLocationSection(request),
              const SizedBox(height: 16),
              _buildDescriptionSection(request),
              const SizedBox(height: 16),
              _buildPaymentSection(request),
              const SizedBox(height: 16),
              if (request.status == 'cancelled') _buildCancellationSection(request),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        final request = _controller.currentRequest.value;
        if (request == null) return const SizedBox.shrink();

        return _buildBottomActions(request);
      }),
    );
  }

  Widget _buildStatusSection(RequestModel request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusIndicator(request.status),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(request.status),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusDescription(request),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getStatusProgress(request.status),
              backgroundColor: ColorConstants.disabledColor,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(request.status)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressStep('Solicitado', 0, request.status),
                _buildProgressStep('Aceito', 1, request.status),
                _buildProgressStep('Concluído', 2, request.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(status),
        color: _getStatusColor(status),
        size: 20,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return ColorConstants.warningColor;
      case 'accepted':
        return ColorConstants.infoColor;
      case 'completed':
        return ColorConstants.successColor;
      case 'cancelled':
        return ColorConstants.errorColor;
      default:
        return ColorConstants.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'accepted':
        return Icons.engineering_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'accepted':
        return 'Aceito';
      case 'completed':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status.capitalize ?? status;
    }
  }

  String _getStatusDescription(RequestModel request) {
    switch (request.status) {
      case 'pending':
        return 'Aguardando aceitação do prestador';
      case 'accepted':
        final formattedDate = DateFormat('dd/MM').format(request.acceptedAt!);
        return 'Aceito em $formattedDate';
      case 'completed':
        final formattedDate = DateFormat('dd/MM').format(request.completedAt!);
        return 'Concluído em $formattedDate';
      case 'cancelled':
        final formattedDate = DateFormat('dd/MM').format(request.cancelledAt!);
        return 'Cancelado em $formattedDate';
      default:
        return '';
    }
  }

  double _getStatusProgress(String status) {
    switch (status) {
      case 'pending':
        return 0.33;
      case 'accepted':
        return 0.66;
      case 'completed':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }

  Widget _buildProgressStep(String label, int step, String currentStatus) {
    final int currentStep = _getStatusStep(currentStatus);
    final bool isActive = step <= currentStep;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? ColorConstants.textPrimaryColor
                : ColorConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'completed':
        return 2;
      default:
        return -1;
    }
  }

  Widget _buildServiceSection(RequestModel request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Serviço',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_repair_service_outlined,
                    color: ColorConstants.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.providerName,
                        style: const TextStyle(
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${request.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(RequestModel request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agendamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScheduleItem(
                  Icons.calendar_today_outlined,
                  'Data',
                  DateFormat('dd/MM/yyyy').format(request.scheduledDate),
                ),
                const SizedBox(width: 24),
                _buildScheduleItem(
                  Icons.access_time,
                  'Horário',
                  request.scheduledTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: ColorConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(RequestModel request) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Local',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 12),
    Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Icon(
    Icons.location_on_outlined,
    size: 20,
    color: ColorConstants.primaryColor,
    ),
    const SizedBox(width: 8),
    Expanded(
    child: Text(
      request.address,
      style: const TextStyle(
        fontSize: 14,
      ),
    ),
    ),
    ],
    ),
      const SizedBox(height: 16),
      Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorConstants.inputFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.map_outlined,
            size: 48,
            color: ColorConstants.primaryColor.withOpacity(0.5),
          ),
        ),
      ),
    ],
    ),
        ),
    );
  }

  Widget _buildDescriptionSection(RequestModel request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              request.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(RequestModel request) {
    final paymentStatus = request.paymentStatus ?? 'pending';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pagamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valor total',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                      Text(
                        'R\$ ${request.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPaymentStatusBadge(paymentStatus),
              ],
            ),
            const SizedBox(height: 12),
            if (request.paymentMethod != null)
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(request.paymentMethod!),
                    size: 20,
                    color: ColorConstants.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPaymentMethodText(request.paymentMethod!),
                    style: const TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = ColorConstants.warningColor;
        label = 'Pendente';
        break;
      case 'processing':
        color = ColorConstants.infoColor;
        label = 'Processando';
        break;
      case 'paid':
        color = ColorConstants.successColor;
        label = 'Pago';
        break;
      case 'failed':
        color = ColorConstants.errorColor;
        label = 'Falhou';
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

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'debit_card':
        return Icons.credit_card;
      case 'pix':
        return Icons.qr_code;
      case 'cash':
        return Icons.attach_money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'debit_card':
        return 'Cartão de Débito';
      case 'pix':
        return 'PIX';
      case 'cash':
        return 'Dinheiro';
      default:
        return method.capitalize ?? method;
    }
  }

  Widget _buildCancellationSection(RequestModel request) {
    if (request.cancellationReason == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motivo do Cancelamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              request.cancellationReason!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(RequestModel request) {
    final isProvider = _authController.userModel.value?.isProvider ?? false;

    if (request.status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: CustomButton(
          label: 'Entre em Contato',
          onPressed: _contactUser,
          type: ButtonType.outline,
          icon: Icons.chat_outlined,
        ),
      );
    }

    if (isProvider) {
      return _buildProviderActions(request);
    } else {
      return _buildClientActions(request);
    }
  }

  Widget _buildProviderActions(RequestModel request) {
    switch (request.status) {
      case 'pending':
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Aceitar',
                  onPressed: () => _updateRequestStatus('accepted'),
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              CustomButton(
                label: 'Recusar',
                onPressed: _showCancellationDialog,
                type: ButtonType.outline,
                icon: Icons.cancel_outlined,
                isFullWidth: false,
              ),
            ],
          ),
        );
      case 'accepted':
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Marcar como Concluído',
                  onPressed: () => _updateRequestStatus('completed'),
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              CustomButton(
                label: 'Contato',
                onPressed: _contactUser,
                type: ButtonType.outline,
                icon: Icons.chat_outlined,
                isFullWidth: false,
              ),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Entre em Contato',
                  onPressed: _contactUser,
                  type: ButtonType.outline,
                  icon: Icons.chat_outlined,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildClientActions(RequestModel request) {
    switch (request.status) {
      case 'pending':
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancelar Solicitação',
                  onPressed: _showCancellationDialog,
                  type: ButtonType.outline,
                  icon: Icons.cancel_outlined,
                ),
              ),
              const SizedBox(width: 16),
              CustomButton(
                label: 'Contato',
                onPressed: _contactUser,
                type: ButtonType.outline,
                icon: Icons.chat_outlined,
                isFullWidth: false,
              ),
            ],
          ),
        );
      case 'accepted':
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancelar Solicitação',
                  onPressed: _showCancellationDialog,
                  type: ButtonType.outline,
                  icon: Icons.cancel_outlined,
                ),
              ),
              const SizedBox(width: 16),
              CustomButton(
                label: 'Contato',
                onPressed: _contactUser,
                type: ButtonType.outline,
                icon: Icons.chat_outlined,
                isFullWidth: false,
              ),
            ],
          ),
        );
      case 'completed':
        final isPaid = request.paymentStatus == 'paid';
        final isRated = request.isRated;

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPaid)
                CustomButton(
                  label: 'Realizar Pagamento',
                  onPressed: _makePayment,
                  icon: Icons.payment,
                ),
              if (isPaid && !isRated) ...[
                if (!isPaid) const SizedBox(height: 12),
                CustomButton(
                  label: 'Avaliar Serviço',
                  onPressed: _addReview,
                  icon: Icons.star_outline,
                ),
              ],
              if (isPaid && isRated || isPaid && !isRated) ...[
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Entre em Contato',
                  onPressed: _contactUser,
                  type: ButtonType.outline,
                  icon: Icons.chat_outlined,
                ),
              ],
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

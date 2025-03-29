import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/data/models/transaction_model.dart';
import 'package:helpper/features/payments/payments_controller.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> with SingleTickerProviderStateMixin {
  final PaymentsController _controller = Get.find<PaymentsController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.loadEarnings();
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
        title: const Text('Ganhos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'Transações'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final currentMonthEarnings = _controller.currentMonthEarnings.value;
      final lastMonthEarnings = _controller.lastMonthEarnings.value;
      final totalEarnings = _controller.totalEarnings.value;
      final pendingPayments = _controller.pendingPayments.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEarningsCard(
              'Total de Ganhos',
              totalEarnings,
              ColorConstants.successColor,
              Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEarningsCard(
                    'Este Mês',
                    currentMonthEarnings,
                    ColorConstants.primaryColor,
                    Icons.calendar_today_outlined,
                    small: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEarningsCard(
                    'Mês Anterior',
                    lastMonthEarnings,
                    ColorConstants.accentColor,
                    Icons.history_outlined,
                    small: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEarningsCard(
              'Pagamentos Pendentes',
              pendingPayments,
              ColorConstants.warningColor,
              Icons.hourglass_empty_outlined,
            ),
            const SizedBox(height: 24),
            const Text(
              'Estatísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatisticsCard(),
            const SizedBox(height: 24),
            const Text(
              'Últimas Transações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentTransactions(),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionsTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (_controller.transactions.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: ColorConstants.textSecondaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'Nenhuma transação encontrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Suas transações aparecerão aqui',
                style: TextStyle(
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.transactions.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final transaction = _controller.transactions[index];
          return _buildTransactionItem(transaction);
        },
      );
    });
  }

  Widget _buildEarningsCard(String title, double amount, Color color, IconData icon, {bool small = false}) {
    return Container(
      padding: EdgeInsets.all(small ? 12 : 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: small ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: small ? 14 : 16,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(amount),
            style: TextStyle(
              fontSize: small ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
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
          _buildStatItem(
            'Serviços Realizados',
            _controller.completedServices.value.toString(),
            Icons.check_circle_outline,
            ColorConstants.successColor,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Serviços Cancelados',
            _controller.canceledServices.value.toString(),
            Icons.cancel_outlined,
            ColorConstants.errorColor,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Valor Médio',
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(_controller.averageAmount.value),
            Icons.insights_outlined,
            ColorConstants.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.textSecondaryColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    if (_controller.transactions.isEmpty) {
      return Container(
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
        child: const Center(
          child: Text(
            'Nenhuma transação recente',
            style: TextStyle(
              color: ColorConstants.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
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
        children: _controller.transactions.take(5).map((transaction) =>
            Column(
              children: [
                _buildTransactionItem(transaction),
                if (_controller.transactions.indexOf(transaction) <
                    min(4, _controller.transactions.length - 1))
                  const Divider(),
              ],
            ),
        ).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getStatusColor(transaction.status).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStatusIcon(transaction.status),
          color: _getStatusColor(transaction.status),
          size: 20,
        ),
      ),
      title: Text(
        transaction.serviceName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy').format(transaction.createdAt),
        style: const TextStyle(
          fontSize: 12,
          color: ColorConstants.textSecondaryColor,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(transaction.amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: transaction.status == 'completed'
                  ? ColorConstants.successColor
                  : ColorConstants.textPrimaryColor,
            ),
          ),
          Text(
            _getStatusText(transaction.status),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(transaction.status),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return ColorConstants.successColor;
      case 'pending':
        return ColorConstants.warningColor;
      case 'cancelled':
        return ColorConstants.errorColor;
      default:
        return ColorConstants.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Concluído';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  int min(int a, int b) => a < b ? a : b;
}

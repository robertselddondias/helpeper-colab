import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/data/models/payment_method_model.dart';
import 'package:helpper/features/payments/payments_controller.dart';
import 'package:helpper/features/payments/screen/add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final PaymentsController _controller = Get.find<PaymentsController>();
  final RxList<PaymentMethodModel> _paymentMethods = <PaymentMethodModel>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    _isLoading.value = true;

    // Simulate loading payment methods
    await Future.delayed(const Duration(seconds: 1));

    _paymentMethods.value = [
      PaymentMethodModel(
        id: '1',
        type: 'credit_card',
        brand: 'Visa',
        lastFourDigits: '4242',
        expiryMonth: 12,
        expiryYear: 25,
        isDefault: true,
      ),
      PaymentMethodModel(
        id: '2',
        type: 'bank_account',
        bankName: 'Banco do Brasil',
        accountType: 'Checking',
        lastFourDigits: '9876',
        isDefault: false,
      ),
    ];

    _isLoading.value = false;
  }

  void _addPaymentMethod() {
    Get.to(() => const AddPaymentMethodScreen());
  }

  void _removePaymentMethod(String id) {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Remover Método de Pagamento'),
        content: const Text('Tem certeza que deseja remover este método de pagamento?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Remove payment method
              _paymentMethods.removeWhere((method) => method.id == id);
              Get.back();

              Get.snackbar(
                'Sucesso',
                'Método de pagamento removido com sucesso',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(String id) {
    final List<PaymentMethodModel> updatedMethods = [];

    for (var method in _paymentMethods) {
      if (method.id == id) {
        updatedMethods.add(method.copyWith(isDefault: true));
      } else {
        updatedMethods.add(method.copyWith(isDefault: false));
      }
    }

    _paymentMethods.value = updatedMethods;

    Get.snackbar(
      'Sucesso',
      'Método de pagamento definido como padrão',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Métodos de Pagamento'),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.credit_card_outlined,
                  size: 64,
                  color: ColorConstants.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum método de pagamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione um método de pagamento para começar',
                  style: TextStyle(
                    color: ColorConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Adicionar Método de Pagamento',
                  onPressed: _addPaymentMethod,
                  icon: Icons.add,
                  isFullWidth: false,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _paymentMethods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  return _buildPaymentMethodCard(method);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                label: 'Adicionar Método de Pagamento',
                onPressed: _addPaymentMethod,
                icon: Icons.add,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel method) {
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
        border: method.isDefault
            ? Border.all(
          color: ColorConstants.primaryColor,
          width: 2,
        )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method.type == 'credit_card'
                      ? Icons.credit_card_outlined
                      : Icons.account_balance_outlined,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.type == 'credit_card'
                              ? method.brand ?? ''
                              : method.bankName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (method.isDefault)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Padrão',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.type == 'credit_card'
                          ? '•••• ${method.lastFourDigits} - Expira em ${method.expiryMonth}/${method.expiryYear}'
                          : '${method.accountType} •••• ${method.lastFourDigits}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: ColorConstants.textSecondaryColor,
                ),
                itemBuilder: (context) => [
                  if (!method.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text('Definir como padrão'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remover', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'default') {
                    _setAsDefault(method.id);
                  } else if (value == 'remove') {
                    _removePaymentMethod(method.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

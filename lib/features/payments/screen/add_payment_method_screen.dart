import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_text_field.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}


class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'credit_card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Adicionar Método de Pagamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de método de pagamento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      'credit_card',
                      'Cartão de Crédito',
                      Icons.credit_card_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeCard(
                      'bank_account',
                      'Conta Bancária',
                      Icons.account_balance_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_selectedType == 'credit_card')
                _buildCreditCardForm()
              else
                _buildBankAccountForm(),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Adicionar',
                onPressed: _addPaymentMethod,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorConstants.primaryColor
                : ColorConstants.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.textPrimaryColor,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Número do Cartão',
          hint: '0000 0000 0000 0000',
          prefixIcon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Data de Validade',
                hint: 'MM/AA',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'CVV',
                hint: '000',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        CustomTextField(
          label: 'Nome no Cartão',
          hint: 'Como aparece no cartão',
          prefixIcon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildBankAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTextField(
          label: 'Nome do Banco',
          hint: 'Ex: Banco do Brasil',
          prefixIcon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          label: 'Agência',
          hint: 'Número da agência',
          prefixIcon: Icons.home_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          label: 'Conta',
          hint: 'Número da conta com dígito',
          prefixIcon: Icons.account_box_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        const Text(
          'Tipo de Conta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.inputFillColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            value: 'Corrente',
            items: ['Corrente', 'Poupança', 'Salário', 'Outro'].map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  void _addPaymentMethod() {
    // Implement payment method addition logic
    Get.back();
    Get.snackbar(
      'Sucesso',
      'Método de pagamento adicionado com sucesso',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}

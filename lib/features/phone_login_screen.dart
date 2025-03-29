import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/validators.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_text_field.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneLogin() {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _phoneController.text.trim();

      // Ensure the phone number starts with +
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+55$phoneNumber'; // Assuming Brazil as default country code
      }

      _authController.signInWithPhone(phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstants.primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text('Login com Telefone'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Digite seu número de telefone',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enviaremos um código de verificação para este número',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Número de telefone',
                  hint: '+55 (00) 00000-0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePhone,
                  onSubmitted: (_) => _handlePhoneLogin(),
                ),
                const SizedBox(height: 32),
                Obx(() => CustomButton(
                  label: 'Enviar código',
                  onPressed: _handlePhoneLogin,
                  isLoading: _authController.isLoading.value,
                )),
                if (_authController.error.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _authController.error.value,
                      style: const TextStyle(
                        color: ColorConstants.errorColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

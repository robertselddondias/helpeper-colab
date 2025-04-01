import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  final AuthController _authController = Get.find<AuthController>();
  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendSeconds = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();

    if (code.length == 6) {
      _authController.verifyPhoneCode(code);
    } else {
      Get.snackbar(
        'Erro',
        'Por favor, insira o código completo de 6 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ColorConstants.errorColor,
        colorText: Colors.white,
      );
    }
  }

  void _resendCode() {
    if (_canResend) {
      // Implementar lógica para reenviar o código
      // ...

      _startResendTimer();

      Get.snackbar(
        'Sucesso',
        'Um novo código foi enviado para o seu telefone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ColorConstants.successColor,
        colorText: Colors.white,
      );
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
        title: const Text('Verificação'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Verificação de Código',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enviamos um código de verificação para o seu telefone. Por favor, digite o código abaixo.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (index) => _buildCodeInput(index),
                ),
              ),
              const SizedBox(height: 40),
              Obx(() => CustomButton(
                label: 'Verificar',
                onPressed: _verifyCode,
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

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não recebeu o código? ',
                    style: TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: _canResend ? _resendCode : null,
                    child: Text(
                      _canResend
                          ? 'Reenviar'
                          : 'Reenviar em $_resendSeconds s',
                      style: TextStyle(
                        color: _canResend
                            ? ColorConstants.primaryColor
                            : ColorConstants.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: ColorConstants.inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? ColorConstants.primaryColor
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textPrimaryColor,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verifyCode();
            }
          }
        },
        onTap: () {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }
}

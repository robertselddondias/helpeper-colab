import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Simulamos um pequeno atraso para mostrar a tela de splash
    Future.delayed(const Duration(seconds: 2), () {
      // Não fazemos nada aqui, apenas deixamos o AuthController gerenciar o fluxo
    });
  }

  Future<void> _checkAuth() async {
    try {
      // Simulamos um atraso mínimo para mostrar a tela de splash
      await Future.delayed(const Duration(seconds: 2));

      // Verificamos se o usuário já está logado
      final AuthController authController = Get.find<AuthController>();
      if (authController.firebaseUser.value != null) {
        // Usuário já está logado, vai para a home
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        // Usuário não está logado, verifica se precisa mostrar onboarding
        final bool hasSeenOnboarding = await _hasSeenOnboarding();
        if (hasSeenOnboarding) {
          Get.offAllNamed(AppRoutes.LOGIN);
        } else {
          Get.offAllNamed(AppRoutes.ONBOARDING);
        }
      }
    } catch (e) {
      debugPrint('Erro no splash: $e');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  Future<bool> _hasSeenOnboarding() async {
    // Na implementação real, usaríamos shared preferences ou outro armazenamento
    // para verificar se o usuário já viu o onboarding
    return false; // Por padrão, mostramos o onboarding
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: SvgPicture.asset(
                  'assets/images/logo-helpper.svg',
                  width: 180,
                  height: 180,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Helpp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Serviços locais em um só lugar',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

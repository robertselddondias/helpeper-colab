import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/utils/validators.dart';
import 'package:helpper/core/widgets/animated_button.dart';
import 'package:helpper/core/widgets/enhanced_text_field.dart';
import 'package:helpper/core/widgets/animated_list_item.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/auth/widgets/social_login_buttons.dart';
import 'package:helpper/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.adaptiveSize(context, 24.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 40)),
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/logo-helpper.svg',
                        height: ResponsiveUtils.adaptiveSize(context, 80),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 40)),
                    AnimatedListItem(
                      index: 0,
                      child: Text(
                        'Bem-vindo de volta',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.adaptiveFontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),
                    AnimatedListItem(
                      index: 1,
                      child: Text(
                        'Faça login para continuar',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),
                    AnimatedListItem(
                      index: 2,
                      child: EnhancedTextField(
                        label: 'Email',
                        hint: 'Digite seu email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateEmail,
                        borderRadius: 16,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
                    AnimatedListItem(
                      index: 3,
                      child: EnhancedTextField(
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        textInputAction: TextInputAction.done,
                        validator: Validators.validatePassword,
                        onSubmitted: (_) => _handleLogin(),
                        borderRadius: 16,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 12)),
                    AnimatedListItem(
                      index: 4,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                          child: Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 24)),
                    AnimatedListItem(
                      index: 5,
                      child: Obx(() => AnimatedButton(
                        label: 'Entrar',
                        onPressed: _handleLogin,
                        isLoading: _authController.isLoading.value,
                        icon: Icons.login_outlined,
                      )),
                    ),
                    if (_authController.error.value.isNotEmpty)
                      AnimatedListItem(
                        index: 6,
                        child: Padding(
                          padding: EdgeInsets.only(top: ResponsiveUtils.adaptiveSize(context, 16.0)),
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUtils.adaptiveSize(context, 12)),
                            decoration: BoxDecoration(
                              color: ColorConstants.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.adaptiveSize(context, 8)
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: ColorConstants.errorColor,
                                  size: ResponsiveUtils.adaptiveSize(context, 18),
                                ),
                                SizedBox(width: ResponsiveUtils.adaptiveSize(context, 8)),
                                Expanded(
                                  child: Text(
                                    _authController.error.value,
                                    style: TextStyle(
                                      color: ColorConstants.errorColor,
                                      fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),
                    AnimatedListItem(
                      index: 7,
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.adaptiveSize(context, 16.0)
                            ),
                            child: Text(
                              'Ou continue com',
                              style: TextStyle(
                                color: ColorConstants.textSecondaryColor,
                                fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 24)),
                    AnimatedListItem(
                      index: 8,
                      child: const SocialLoginButtons(),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),
                    AnimatedListItem(
                      index: 9,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem uma conta? ',
                              style: TextStyle(
                                color: ColorConstants.textSecondaryColor,
                                fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.REGISTER),
                              child: Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

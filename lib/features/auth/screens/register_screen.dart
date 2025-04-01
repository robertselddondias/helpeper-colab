import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/utils/validators.dart';
import 'package:helpper/core/widgets/animated_button.dart';
import 'package:helpper/core/widgets/animated_list_item.dart';
import 'package:helpper/core/widgets/enhanced_text_field.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  bool _isProvider = true;

  // Animation controllers for staggered animations
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar(
          'Erro',
          'As senhas não coincidem',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorConstants.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      _authController.signUpWithEmail(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
        _isProvider,
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
          icon: Container(
            padding: EdgeInsets.all(ResponsiveUtils.adaptiveSize(context, 8)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: ColorConstants.primaryColor,
              size: ResponsiveUtils.adaptiveSize(context, 16),
            ),
          ),
          onPressed: () => Get.back(),
        ),
      ),
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
                    AnimatedListItem(
                      index: 0,
                      child: Text(
                        'Criar Conta',
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
                        'Preencha seus dados para começar',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),

                    // Personal Information Section
                    AnimatedListItem(
                      index: 2,
                      child: EnhancedTextField(
                        label: 'Nome completo',
                        hint: 'Digite seu nome completo',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateName,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),

                    AnimatedListItem(
                      index: 3,
                      child: EnhancedTextField(
                        label: 'Email',
                        hint: 'Digite seu email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateEmail,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),

                    AnimatedListItem(
                      index: 4,
                      child: EnhancedTextField(
                        label: 'Telefone',
                        hint: 'Digite seu telefone com DDD',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validatePhone,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),

                    // Password Section
                    AnimatedListItem(
                      index: 5,
                      child: EnhancedTextField(
                        label: 'Senha',
                        hint: 'Crie uma senha',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validatePassword,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),

                    AnimatedListItem(
                      index: 6,
                      child: EnhancedTextField(
                        label: 'Confirmar senha',
                        hint: 'Digite a senha novamente',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        textInputAction: TextInputAction.done,
                        validator: Validators.validatePassword,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 24)),

                    // Account Type Section
                    AnimatedListItem(
                      index: 7,
                      child: Text(
                        'Tipo de conta',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 12)),

                    AnimatedListItem(
                      index: 8,
                      child: Row(
                        children: [
                          Expanded(
                            child: _AccountTypeCard(
                              title: 'Prestador',
                              description: 'Quero oferecer serviços',
                              icon: Icons.handyman_outlined,
                              isSelected: _isProvider,
                              onTap: () {
                                setState(() {
                                  _isProvider = true;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.adaptiveSize(context, 16)),
                          Expanded(
                            child: _AccountTypeCard(
                              title: 'Cliente',
                              description: 'Quero contratar serviços',
                              icon: Icons.person_search_outlined,
                              isSelected: !_isProvider,
                              onTap: () {
                                setState(() {
                                  _isProvider = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),

                    // Register Button
                    AnimatedListItem(
                      index: 9,
                      child: Obx(() => AnimatedButton(
                        label: 'Cadastrar',
                        onPressed: _handleRegister,
                        isLoading: _authController.isLoading.value,
                        icon: Icons.app_registration,
                      )),
                    ),

                    // Error Message
                    if (_authController.error.value.isNotEmpty)
                      AnimatedListItem(
                        index: 10,
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

                    SizedBox(height: ResponsiveUtils.adaptiveSize(context, 24)),

                    // Login Link
                    AnimatedListItem(
                      index: 11,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem uma conta? ',
                              style: TextStyle(
                                color: ColorConstants.textSecondaryColor,
                                fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Faça login',
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

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(ResponsiveUtils.adaptiveSize(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              ResponsiveUtils.adaptiveSize(context, 16)
          ),
          border: Border.all(
            color: isSelected
                ? ColorConstants.primaryColor
                : ColorConstants.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: ColorConstants.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon container
            Container(
              width: ResponsiveUtils.adaptiveSize(context, 48),
              height: ResponsiveUtils.adaptiveSize(context, 48),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.adaptiveSize(context, 24),
                color: isSelected
                    ? Colors.white
                    : ColorConstants.primaryColor,
              ),
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 12)),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 4)),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 12),
                color: ColorConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Selection indicator
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),
            if (isSelected)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.adaptiveSize(context, 8),
                  vertical: ResponsiveUtils.adaptiveSize(context, 4),
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      ResponsiveUtils.adaptiveSize(context, 12)
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: ResponsiveUtils.adaptiveSize(context, 12),
                      color: ColorConstants.primaryColor,
                    ),
                    SizedBox(width: ResponsiveUtils.adaptiveSize(context, 4)),
                    Text(
                      'Selecionado',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.adaptiveFontSize(context, 10),
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

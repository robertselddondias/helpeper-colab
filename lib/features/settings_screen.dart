import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = Get.find<AuthController>();
  String _appVersion = '';
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  String _selectedLanguage = 'Português';
  String _selectedTheme = 'Claro';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _signOut() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _authController.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          _buildSection('Conta', [
            _buildSettingItem(
              'Perfil',
              'Editar seus dados pessoais',
              Icons.person_outline,
              onTap: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
            ),
            _buildSettingItem(
              'Métodos de Pagamento',
              'Gerenciar suas formas de pagamento',
              Icons.credit_card_outlined,
              onTap: () => Get.toNamed(AppRoutes.PAYMENT_METHODS),
            ),
            _buildSettingItem(
              'Endereços',
              'Gerenciar seus endereços',
              Icons.location_on_outlined,
              onTap: () {},
            ),
          ]),
          _buildSection('Preferências', [
            _buildSwitchSettingItem(
              'Notificações Push',
              'Receber notificações do app',
              Icons.notifications_outlined,
              _notificationsEnabled,
                  (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchSettingItem(
              'Emails',
              'Receber emails sobre ofertas e novidades',
              Icons.email_outlined,
              _emailNotificationsEnabled,
                  (value) {
                setState(() {
                  _emailNotificationsEnabled = value;
                });
              },
            ),
            _buildSelectSettingItem(
              'Idioma',
              'Alterar o idioma do aplicativo',
              Icons.language_outlined,
              _selectedLanguage,
                  () => _showLanguageOptions(),
            ),
            _buildSelectSettingItem(
              'Tema',
              'Personalizar a aparência do app',
              Icons.palette_outlined,
              _selectedTheme,
                  () => _showThemeOptions(),
            ),
          ]),
          _buildSection('Sobre', [
            _buildSettingItem(
              'Termos de Uso',
              'Leia os termos de uso do app',
              Icons.description_outlined,
              onTap: () {},
            ),
            _buildSettingItem(
              'Política de Privacidade',
              'Como seus dados são utilizados',
              Icons.privacy_tip_outlined,
              onTap: () {},
            ),
            _buildSettingItem(
              'Ajuda e Suporte',
              'Entre em contato conosco',
              Icons.help_outline,
              onTap: () {},
            ),
            _buildSettingItem(
              'Versão do Aplicativo',
              _appVersion,
              Icons.info_outline,
              onTap: () {},
              showArrow: false,
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: _signOut,
              style: TextButton.styleFrom(
                foregroundColor: ColorConstants.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Sair da Conta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
        ),
        Container(
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
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
      String title,
      String subtitle,
      IconData icon, {
        required VoidCallback onTap,
        bool showArrow = true,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ColorConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                color: ColorConstants.textSecondaryColor,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ColorConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ColorConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSettingItem(
      String title,
      String subtitle,
      IconData icon,
      String value,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ColorConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: ColorConstants.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Selecionar Idioma',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...[
              'Português',
              'English',
              'Español',
            ].map((lang) => ListTile(
              title: Text(lang),
              trailing: _selectedLanguage == lang
                  ? const Icon(
                Icons.check,
                color: ColorConstants.primaryColor,
              )
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = lang;
                });
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showThemeOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Selecionar Tema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...[
              'Claro',
              'Escuro',
              'Sistema',
            ].map((theme) => ListTile(
              title: Text(theme),
              trailing: _selectedTheme == theme
                  ? const Icon(
                Icons.check,
                color: ColorConstants.primaryColor,
              )
                  : null,
              onTap: () {
                setState(() {
                  _selectedTheme = theme;
                });
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/responsive_utils.dart';
import 'package:helpper/core/utils/validators.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_text_field.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/profile/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();

  final ProfileController _profileController = Get.find<ProfileController>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<String> _skills = <String>[].obs;
  final TextEditingController _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authController.userModel.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _bioController.text = user.bio ?? '';
      _addressController.text = user.address ?? '';
      _skills.value = List<String>.from(user.skills);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'address': _addressController.text.trim(),
        'skills': _skills,
      };

      _profileController.updateProfile(data);
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      _skills.add(skill);
      _skillController.clear();
    }
  }

  void _removeSkill(String skill) {
    _skills.remove(skill);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: constraints.maxWidth > 600
                  ? 600
                  : constraints.maxWidth,
              child: _buildProfileForm(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            Center(
              child: _buildProfileAvatar(context),
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),
            _buildTextField(
              context,
              label: 'Nome completo',
              hint: 'Digite seu nome completo',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
            _buildTextField(
              context,
              label: 'Email',
              hint: 'Digite seu email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              enabled: false,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
            _buildTextField(
              context,
              label: 'Telefone',
              hint: 'Digite seu telefone com DDD',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
            _buildTextField(
              context,
              label: 'Biografia',
              hint: 'Fale um pouco sobre você e suas experiências',
              controller: _bioController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              validator: Validators.validateOptional,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
            _buildTextField(
              context,
              label: 'Endereço',
              hint: 'Digite seu endereço',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
              validator: Validators.validateOptional,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
            _buildSkillsSection(context),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 32)),
            CustomButton(
              label: 'Salvar alterações',
              onPressed: _handleSave,
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)), // Extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          final user = _authController.userModel.value;
          final avatarRadius = ResponsiveUtils.adaptiveSize(context, 50);
          return CircleAvatar(
            radius: avatarRadius,
            backgroundColor: ColorConstants.primaryColor.withOpacity(0.1),
            child: user?.photoUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(avatarRadius),
              child: CachedNetworkImage(
                imageUrl: user!.photoUrl!,
                fit: BoxFit.cover,
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                placeholder: (context, url) =>
                const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                const Icon(Icons.person, size: 50),
              ),
            )
                : Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 40),
                fontWeight: FontWeight.bold,
                color: ColorConstants.primaryColor,
              ),
            ),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: ResponsiveUtils.adaptiveSize(context, 32),
            height: ResponsiveUtils.adaptiveSize(context, 32),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: ResponsiveUtils.adaptiveSize(context, 18),
              ),
              onPressed: () => _profileController.pickProfileImage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required String hint,
        required TextEditingController controller,
        IconData? prefixIcon,
        TextInputType? keyboardType,
        int? maxLines,
        String? Function(String?)? validator,
        bool enabled = true,
      }) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: prefixIcon,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines ?? 1,
      textInputAction: TextInputAction.next,
      validator: validator,
      enabled: enabled,
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Obx(() {
      final user = _authController.userModel.value;
      if (user != null && user.isProvider) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habilidades',
              style: TextStyle(
                fontSize: ResponsiveUtils.adaptiveFontSize(context, 14),
                fontWeight: FontWeight.w500,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 8)),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hint: 'Adicionar uma habilidade',
                    controller: _skillController,
                    prefixIcon: Icons.add_circle_outline,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.adaptiveSize(context, 8)),
                CustomButton(
                  label: 'Adicionar',
                  onPressed: _addSkill,
                  type: ButtonType.secondary,
                  size: ButtonSize.small,
                  isFullWidth: false,
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.adaptiveSize(context, 16)),
            Wrap(
              spacing: ResponsiveUtils.adaptiveSize(context, 8),
              runSpacing: ResponsiveUtils.adaptiveSize(context, 8),
              children: _skills.map((skill) => _buildSkillChip(context, skill)).toList(),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildSkillChip(BuildContext context, String skill) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.adaptiveSize(context, 12),
        vertical: ResponsiveUtils.adaptiveSize(context, 8),
      ),
      decoration: BoxDecoration(
        color: ColorConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              color: ColorConstants.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: ResponsiveUtils.adaptiveSize(context, 4)),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: Icon(
              Icons.close,
              size: ResponsiveUtils.adaptiveSize(context, 16),
              color: ColorConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

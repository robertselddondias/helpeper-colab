import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Obx(() {
                          final user = _authController.userModel.value;
                          return CircleAvatar(
                            radius: 50,
                            backgroundColor: ColorConstants.primaryColor.withOpacity(0.1),
                            child: user?.photoUrl != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: user!.photoUrl!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.person, size: 50),
                              ),
                            )
                                : Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
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
                            width: 32,
                            height: 32,
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
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => _profileController.pickProfileImage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Nome completo',
                    hint: 'Digite seu nome completo',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Digite seu email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Telefone',
                    hint: 'Digite seu telefone com DDD',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Biografia',
                    hint: 'Fale um pouco sobre você e suas experiências',
                    controller: _bioController,
                    prefixIcon: Icons.description_outlined,
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateOptional,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Endereço',
                    hint: 'Digite seu endereço',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_outlined,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateOptional,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final user = _authController.userModel.value;
                    if (user != null && user.isProvider) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Habilidades',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                              const SizedBox(width: 8),
                              CustomButton(
                                label: 'Adicionar',
                                onPressed: _addSkill,
                                type: ButtonType.secondary,
                                size: ButtonSize.small,
                                isFullWidth: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(() => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
                          )),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Salvar alterações',
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: const Icon(
              Icons.close,
              size: 16,
              color: ColorConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

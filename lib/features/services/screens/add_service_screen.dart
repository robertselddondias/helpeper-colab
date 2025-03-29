import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/validators.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_text_field.dart';
import 'package:helpper/features/services/services_controller.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();

  final ServicesController _controller = Get.find<ServicesController>();
  final ImagePicker _imagePicker = ImagePicker();

  final RxList<File> _selectedImages = <File>[].obs;
  final RxString _selectedCategory = ''.obs;
  final RxList<String> _selectedSubCategories = <String>[].obs;
  final RxString _selectedPriceType = 'hora'.obs;

  final List<String> _priceTypes = ['hora', 'dia', 'serviço', 'semana', 'mês'];

  @override
  void initState() {
    super.initState();

    // Se for uma edição, carrega os dados do serviço
    if (Get.arguments != null) {
      final service = Get.arguments;

      _titleController.text = service.title;
      _descriptionController.text = service.description;
      _priceController.text = service.price.toString();
      _addressController.text = service.address ?? '';

      _selectedCategory.value = service.category;
      _selectedSubCategories.value = List<String>.from(service.subCategories);
      _selectedPriceType.value = service.priceType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 800,
      );

      if (images.isNotEmpty) {
        for (var image in images) {
          _selectedImages.add(File(image.path));
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível selecionar as imagens',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _removeImage(int index) {
    _selectedImages.removeAt(index);
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory.value.isEmpty) {
        Get.snackbar(
          'Erro',
          'Selecione uma categoria para o serviço',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorConstants.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      if (_selectedImages.isEmpty && Get.arguments == null) {
        Get.snackbar(
          'Erro',
          'Adicione pelo menos uma imagem para o serviço',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorConstants.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      final serviceData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.replaceAll(',', '.')),
        'priceType': _selectedPriceType.value,
        'category': _selectedCategory.value,
        'subCategories': _selectedSubCategories,
        'address': _addressController.text.trim(),
      };

      if (Get.arguments != null) {
        // Editar serviço existente
        _controller.updateService(
          Get.arguments.id,
          serviceData,
          _selectedImages,
        );
      } else {
        // Adicionar novo serviço
        _controller.addService(
          serviceData,
          _selectedImages,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = Get.arguments != null;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Serviço' : 'Adicionar Serviço'),
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
                  CustomTextField(
                    label: 'Título do serviço',
                    hint: 'Ex: Pintura residencial',
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateServiceTitle,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Descrição detalhada',
                    hint: 'Descreva seu serviço em detalhes, incluindo experiência e diferenciais',
                    controller: _descriptionController,
                    maxLines: 5,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateServiceDescription,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: 'Preço',
                          hint: 'Ex: 50,00',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.attach_money,
                          validator: Validators.validateServicePrice,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+([,\.]\d{0,2})?$')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipo de preço',
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
                              child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPriceType.value,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  items: _priceTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        'Por $type',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _selectedPriceType.value = value;
                                    }
                                  },
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Categoria',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _controller.categories.map((category) {
                      final isSelected = _selectedCategory.value == category;

                      return GestureDetector(
                        onTap: () {
                          _selectedCategory.value = category;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorConstants.primaryColor
                                : ColorConstants.inputFillColor,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? null
                                : Border.all(
                              color: ColorConstants.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : ColorConstants.textPrimaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  const SizedBox(height: 24),
                  const Text(
                    'Subcategorias',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final subCategories = _controller.getSubcategories(_selectedCategory.value);

                    if (subCategories.isEmpty) {
                      return const Text(
                        'Selecione uma categoria primeiro',
                        style: TextStyle(
                          color: ColorConstants.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subCategories.map((subCategory) {
                        final isSelected = _selectedSubCategories.contains(subCategory);

                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              _selectedSubCategories.remove(subCategory);
                            } else {
                              _selectedSubCategories.add(subCategory);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorConstants.accentColor
                                  : ColorConstants.inputFillColor,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                color: ColorConstants.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              subCategory,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : ColorConstants.textPrimaryColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Endereço (opcional)',
                    hint: 'Digite o endereço onde o serviço é oferecido',
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.location_on_outlined,
                    validator: Validators.validateOptional,
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagens do serviço',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => _selectedImages.isEmpty && Get.arguments == null
                          ? _buildEmptyImagesView()
                          : _buildImagesGrid(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Obx(() => CustomButton(
                    label: isEditing ? 'Salvar alterações' : 'Adicionar serviço',
                    onPressed: _handleSave,
                    isLoading: _controller.isLoading.value,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImagesView() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: ColorConstants.inputFillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorConstants.borderColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: ColorConstants.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Adicionar imagens',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Recomendado: pelo menos 3 imagens',
              style: TextStyle(
                fontSize: 14,
                color: ColorConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid() {
    final isEditing = Get.arguments != null;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _selectedImages.length + (isEditing ? 1 : 0) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Botão para adicionar mais imagens
              return GestureDetector(
                onTap: _pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorConstants.borderColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 24,
                        color: ColorConstants.primaryColor,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adicionar',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final imageIndex = index - 1;

            if (isEditing && imageIndex == _selectedImages.length) {
              // Mostrar imagens existentes
              return GestureDetector(
                onTap: () {
                  // Implementar visualização de imagem
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(Get.arguments.images[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (Get.arguments.images.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${Get.arguments.images.length - 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            // Mostrar imagem selecionada
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_selectedImages[imageIndex]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(imageIndex),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: ColorConstants.infoColor,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Adicione fotos de qualidade que mostrem bem o seu serviço',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

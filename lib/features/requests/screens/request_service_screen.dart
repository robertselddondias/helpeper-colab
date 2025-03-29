import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/utils/validators.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_text_field.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/requests/requests_controller.dart';

class RequestServiceScreen extends StatefulWidget {
  const RequestServiceScreen({Key? key}) : super(key: key);

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  final RequestsController _controller = Get.find<RequestsController>();

  late ServiceModel service;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String selectedTime = '09:00';
  final List<String> timeSlots = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00',
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
  ];

  @override
  void initState() {
    super.initState();
    service = Get.arguments as ServiceModel;
    if (service.address != null && service.address!.isNotEmpty) {
      _addressController.text = service.address!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: ColorConstants.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      // Get the provider name from the service's providerId
      final providerName = await _fetchProviderName(service.providerId);

      final requestData = {
        'serviceId': service.id,
        'serviceName': service.title,
        'providerId': service.providerId,
        'providerName': providerName, // Use the fetched provider name
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'scheduledDate': selectedDate,
        'scheduledTime': selectedTime,
        'amount': service.price,
      };

      _controller.createRequest(requestData);
    }
  }

  Future<String> _fetchProviderName(String providerId) async {
    try {
      // Get the provider's information from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get();

      if (doc.exists) {
        // Return the provider's name from the user document
        return doc.data()?['name'] ?? 'Prestador';
      }

      return 'Prestador'; // Default name if user not found
    } catch (e) {
      debugPrint('Error fetching provider name: $e');
      return 'Prestador'; // Default name on error
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Solicitar Serviço'),
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
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        if (service.images.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              service.images.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: ColorConstants.shimmerBaseColor,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.home_repair_service_outlined,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'R\$ ${service.price.toStringAsFixed(2)} / ${service.priceType}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Descreva sua necessidade',
                    hint: 'Forneça detalhes sobre o serviço que você precisa',
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (value) => Validators.validateNotEmpty(value, 'descrição'),
                    prefixIcon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Endereço',
                    hint: 'Informe o endereço onde o serviço será realizado',
                    controller: _addressController,
                    validator: Validators.validateAddress,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Data do serviço',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorConstants.inputFillColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: ColorConstants.primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: ColorConstants.textSecondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Horário',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ColorConstants.inputFillColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTime,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: ColorConstants.textSecondaryColor,
                        ),
                        items: timeSlots.map((String time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedTime = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Resumo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        _buildSummaryItem(
                          'Serviço',
                          service.title,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryItem(
                          'Data',
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryItem(
                          'Horário',
                          selectedTime,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryItem(
                          'Preço',
                          'R\$ ${service.price.toStringAsFixed(2)}',
                          valueColor: ColorConstants.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() => CustomButton(
                    label: 'Solicitar Serviço',
                    onPressed: _submitRequest,
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

  Widget _buildSummaryItem(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? ColorConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}

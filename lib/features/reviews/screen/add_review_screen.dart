import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/core/widgets/custom_text_field.dart';
import 'package:helpper/features/reviews/reviews_controller.dart';
import 'package:helpper/data/models/request_model.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({Key? key}) : super(key: key);

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ReviewsController _controller = Get.find<ReviewsController>();

  late RequestModel request;
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    request = Get.arguments as RequestModel;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      final reviewData = {
        'serviceId': request.serviceId,
        'providerId': request.providerId,
        'requestId': request.id,
        'rating': _rating,
        'comment': _commentController.text.trim(),
      };

      _controller.addReview(reviewData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Avaliar Serviço'),
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
                    child: Column(
                      children: [
                        const Text(
                          'Como foi sua experiência com',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorConstants.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.serviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Prestador: ${request.providerName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: ColorConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sua avaliação',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = starValue;
                            });
                          },
                          child: Icon(
                            starValue <= _rating ? Icons.star : Icons.star_border,
                            color: ColorConstants.starColor,
                            size: 40,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Comentário (opcional)',
                    hint: 'Conte sua experiência com este serviço',
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 500,
                    showCounter: true,
                  ),
                  const SizedBox(height: 32),
                  Obx(() => CustomButton(
                    label: 'Enviar Avaliação',
                    onPressed: _submitReview,
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
}

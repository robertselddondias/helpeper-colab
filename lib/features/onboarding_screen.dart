import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/core/widgets/custom_button.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:helpper/core/constants/color_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Encontre serviços locais',
      'description': 'Encontre os melhores prestadores de serviços perto de você com apenas alguns toques.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Contrate com segurança',
      'description': 'Todos os prestadores são verificados e avaliados pela comunidade.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Ofereça seus serviços',
      'description': 'É um profissional? Cadastre seus serviços e comece a receber solicitações.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _markOnboardingAsSeen() async {
    // Na implementação real, isso salvaria nas shared preferences
    // await SharedPreferences.getInstance()
    //    .then((prefs) => prefs.setBool('hasSeenOnboarding', true));
  }

  void _navigateToLogin() {
    _markOnboardingAsSeen();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text('Pular'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildPage(
                    _onboardingData[index]['title'],
                    _onboardingData[index]['description'],
                    _onboardingData[index]['image'],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => _buildDot(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: _currentPage == _onboardingData.length - 1
                        ? 'Começar agora'
                        : 'Próximo',
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _navigateToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: _currentPage == _onboardingData.length - 1
                        ? Icons.login
                        : Icons.arrow_forward,
                    iconAfterText: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String title, String description, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 250,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: ColorConstants.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? ColorConstants.primaryColor
            : ColorConstants.disabledColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

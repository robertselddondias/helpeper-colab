import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/core/constants/color_constants.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/chat/screens/chats_list_screen.dart';
import 'package:helpper/features/profile/screens/profile_screen.dart';
import 'package:helpper/features/requests/screens/requests_screen.dart';
import 'package:helpper/features/services/screens/services_list_screen.dart';
import 'package:helpper/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final RxInt _currentIndex = 0.obs;

  final List<Widget> _screens = [
    const ServicesListScreen(),
    const RequestsScreen(),
    const ChatsListScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Serviços',
    'Solicitações',
    'Conversas',
    'Perfil',
  ];

  void _onItemTapped(int index) {
    _currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: _currentIndex.value,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.value,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ColorConstants.primaryColor,
        unselectedItemColor: ColorConstants.textSecondaryColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Solicitações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Conversas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex.value == 0 && _authController.userModel.value?.isProvider == true
          ? FloatingActionButton(
        backgroundColor: ColorConstants.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Get.toNamed(AppRoutes.ADD_SERVICE),
      )
          : null,
    ));
  }
}

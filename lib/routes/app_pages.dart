import 'package:get/get.dart';
import 'package:helpper/features/auth/screens/login_screen.dart';
import 'package:helpper/features/auth/screens/register_screen.dart';
import 'package:helpper/features/auth/screens/verification_screen.dart';
import 'package:helpper/features/chat/chat_binding.dart';
import 'package:helpper/features/chat/screens/chat_detail_screen.dart';
import 'package:helpper/features/chat/screens/chats_list_screen.dart';
import 'package:helpper/features/forgot_password_screen.dart';
import 'package:helpper/features/home_screen.dart';
import 'package:helpper/features/notifications/screen/notifications_screen.dart';
import 'package:helpper/features/onboarding_screen.dart';
import 'package:helpper/features/payments/screen/earnings_screen.dart';
import 'package:helpper/features/payments/screen/payment_methods_screen.dart';
import 'package:helpper/features/phone_login_screen.dart';
import 'package:helpper/features/profile/screens/edit_profile_screen.dart';
import 'package:helpper/features/profile/screens/profile_screen.dart';
import 'package:helpper/features/requests/screens/request_detail_screen.dart';
import 'package:helpper/features/search_screen.dart';
import 'package:helpper/features/services/screens/add_service_screen.dart';
import 'package:helpper/features/services/screens/service_detail_screen.dart';
import 'package:helpper/features/services/screens/services_list_screen.dart';
import 'package:helpper/features/settings_screen.dart';
import 'package:helpper/features/splash_screen.dart';
import 'package:helpper/routes/app_routes.dart';

class AppPages {
  static final routes = [
    // Rotas principais
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),

    // Autenticação
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VERIFICATION,
      page: () => const VerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PHONE_LOGIN,
      page: () => const PhoneLoginScreen(),
      transition: Transition.rightToLeft,
    ),

    // Perfil
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Serviços
    GetPage(
      name: AppRoutes.SERVICES,
      page: () => const ServicesListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ADD_SERVICE,
      page: () => const AddServiceScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SERVICE_DETAIL,
      page: () => const ServiceDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SEARCH,
      page: () => const SearchScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.REQUEST_DETAIL,
      page: () => const RequestDetailScreen(),
      transition: Transition.rightToLeft,
    ),

    // Chats
    GetPage(
      name: AppRoutes.CHATS,
      page: () => const ChatsListScreen(),
      binding: ChatBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.CHAT_DETAIL,
      page: () => const ChatDetailScreen(),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
    ),

    // Notificações
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Pagamentos
    GetPage(
      name: AppRoutes.EARNINGS,
      page: () => const EarningsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PAYMENT_METHODS,
      page: () => const PaymentMethodsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

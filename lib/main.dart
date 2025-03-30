import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpper/core/services/storage_service.dart';
import 'package:helpper/core/theme/app_theme.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/chat/chat_controller.dart';
import 'package:helpper/features/notifications/notifications_controller.dart';
import 'package:helpper/features/payments/payments_controller.dart';
import 'package:helpper/features/profile/profile_controller.dart';
import 'package:helpper/features/requests/requests_controller.dart';
import 'package:helpper/features/reviews/reviews_controller.dart';
import 'package:helpper/features/services/services_controller.dart';
import 'package:helpper/routes/app_pages.dart';
import 'package:helpper/routes/app_routes.dart';
import 'package:helpper/data/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase services
  await Get.putAsync(() => FirebaseService().init());

  final storageService = StorageService();
  Get.put(storageService);

  // Configure app orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // Setup controllers
  _setupControllers();

  runApp(const HelppApp());
}

void _setupControllers() {
  Get.put(AuthController(), permanent: true);

  Get.lazyPut(() => ServicesController(), fenix: true);

  Get.lazyPut(() => RequestsController(), fenix: true);

  Get.lazyPut(() => ProfileController(), fenix: true);

  Get.lazyPut(() => ChatController(), fenix: true);

  Get.lazyPut(() => ReviewsController(), fenix: true);
  Get.lazyPut(() => PaymentsController(), fenix: true);

  Get.lazyPut(() => NotificationsController(), fenix: true);
}

class HelppApp extends StatelessWidget {
  const HelppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Helpp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Can be changed to .system or .dark
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
      locale: const Locale('pt', 'BR'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

abstract class AppRoutes {
  // Rotas principais
  static const String SPLASH = '/splash';
  static const String ONBOARDING = '/onboarding';
  static const String HOME = '/home';

  // Rotas de autenticação
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String VERIFICATION = '/verification';
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String PHONE_LOGIN = '/phone-login';

  // Rotas de perfil
  static const String PROFILE = '/profile';
  static const String EDIT_PROFILE = '/edit-profile';
  static const String SETTINGS = '/settings';

  // Rotas de serviços
  static const String SERVICES = '/services';
  static const String ADD_SERVICE = '/add-service';
  static const String SERVICE_DETAIL = '/service-detail';
  static const String CATEGORY_SERVICES = '/category-services';
  static const String SEARCH = '/search';

  // Rotas de solicitações
  static const String REQUESTS = '/requests';
  static const String REQUEST_DETAIL = '/request-detail';
  static const String REQUEST_SERVICE = '/request-service';

  // Rotas de avaliações
  static const String REVIEWS = '/reviews';
  static const String ADD_REVIEW = '/add-review';

  // Rotas de chat
  static const String CHATS = '/chats';
  static const String CHAT_DETAIL = '/chat-detail';

  // Rotas de notificações
  static const String NOTIFICATIONS = '/notifications';

  // Rotas de pagamentos
  static const String EARNINGS = '/earnings';
  static const String PAYMENT_METHODS = '/payment-methods';
}

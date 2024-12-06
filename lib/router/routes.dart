class Routes {
  Routes._();

  static const String splash = '/';
  static const String buyerHome = '/buyer-home';
  static const String creatorHome = '/creator-home';
  static const String ticket = '/ticket';
  static const String profile = '/profile';

  static const String login = '/login';
  static const String register = '/register';

  static const String editProfile = '/edit-profile';
  static const String eventDetail = '/event/:eventId';
  static String getEventDetailPath(String eventId) => '/event/$eventId';

  // Event creator
  static const String eventManagement = '/event-management';
  static const String createEvent = '/create-event';
}

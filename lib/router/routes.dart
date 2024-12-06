class Routes {
  Routes._();

  static const String home = '/home';
  static const String ticket = '/ticket';
  static const String profile = '/profile';

  static const String login = '/login';
  static const String register = '/register';

  static const String editProfile = '/edit-profile';
  static const String eventDetail = '/event/:eventId';
  static String getEventDetailPath(String eventId) => '/event/$eventId';
  static const String createEvent = '/create-event';
}

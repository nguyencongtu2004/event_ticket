class Api {
  // 10.0.2.2 -> localhost for Android emulator
  // static const String baseUrl = 'http://10.0.2.2:3001/api/';
  static const String baseUrl = 'https://b3510dzk-3001.asse.devtunnels.ms/api/';

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';

  // User
  static const String getUserInfo = 'users/information';
  static const String updateUserInfo = 'users/update';
  static const String search = 'users/search';

  // University
  static const String getUniversities = 'universities';
  static String getFacultiesByUniversityId(String universityId) =>
      'universities/$universityId/faculties';

  // Category
  static const String getCategories = 'categories';

  // Event
  static const String getEvents = 'events';
  static String getEventDetail(String eventId) => 'events/$eventId';
  static const String createEvent = 'events/create';
  static String deleteEvent(String eventId) => 'events/$eventId';
  static String updateEvent(String eventId) => 'events/$eventId';

  // ticket
  static const String bookTicket = 'ticket/book';
}

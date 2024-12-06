class Api {
  // 10.0.2.2 -> localhost for Android emulator
  static const String baseUrl = 'http://10.0.2.2:3001/api/';

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';

  // User
  static const String getUserInfo = 'users/information';
  static const String updateUserInfo = 'users/update';

  // University
  static const String getUniversities = 'universities';
  static String getFacultiesByUniversityId(String universityId) =>
      'universities/$universityId/faculties';

  // Category
  static const String getCategories = 'categories';

  // Event
  static const String getEvents = 'events';
  static String getEventDetail(String eventId) => 'events/$eventId';
}

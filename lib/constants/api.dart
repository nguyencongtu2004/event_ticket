// import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  // static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  // static const String baseUrl = 'https://b3510dzk-3001.asse.devtunnels.ms/api/';
  static const String baseUrl = 'http://localhost:3001/api/';

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String fcmToken = 'auth/fcm-token';
  static const String forgetPassword = 'auth/forget-password';

  // User
  static const String getUserInfo = 'users/information';
  static const String updateUserInfo = 'users/update';
  static const String search = 'users/search';
  static const String getAllUsers = 'users/all';
  static String deleteUser(String userId) => 'users/$userId/delete';

  // University
  static const String getUniversitiesWithAll = 'universities/all';

  static const String getUniversities = 'universities';
  static const String createUniversity = 'universities';
  static String updateUniversity(String universityId) =>
      'universities/$universityId';
  static String deleteUniversity(String universityId) =>
      'universities/$universityId';

  static String getFacultiesByUniversityId(String universityId) =>
      'universities/$universityId/faculties';
  static const String createFaculty = 'faculties';
  static String updateFaculty(String id) => 'faculties/$id';
  static String deleteFaculty(String id) => 'faculties/$id';
  static String getMajorsByFacultyId(String facultyId) =>
      'faculties/$facultyId/majors';
  static const String createMajor = 'faculties/majors';
  static String updateMajor(String id) => 'faculties/major/$id';
  static String deleteMajor(String id) => 'faculties/major/$id';

  // Category
  static const String getCategories = 'categories';

  // Event
  static const String getEvents = 'events';
  static const String getManagementEvents = 'events/management';
  static String getEventDetail(String eventId) => 'events/$eventId';
  static const String createEvent = 'events/create';
  static String deleteEvent(String eventId) => 'events/$eventId';
  static String updateEvent(String eventId) => 'events/$eventId';
  static const String searchEvents = 'events/search';
  static String getEventAttendees(String eventId) => 'events/$eventId/participants';

  // ticket
  static const String bookTicket = 'ticket/book';
  static const String getTicketHistory = 'ticket/history';
  static String getTicketDetail(String ticketId) => 'ticket/$ticketId';
  static String cancelTicket(String ticketId) => 'ticket/$ticketId/cancel';
  static const String checkIn = 'ticket/check-in';
  static const String checkInByStudentId = 'ticket/check-in-by-student-id';
  static String transferTicket(String ticketId) => 'ticket/$ticketId/transfer';
  static String confirmTransferTicket(String ticketId) =>
      'ticket/$ticketId/confirm';
  static String rejectTransferTicket(String ticketId) =>
      'ticket/$ticketId/reject';
  static const String getTransferTicket = 'ticket/transferring-ticket';

  // Forum
  static const String getConversasions = 'conversations';
  static String getConversasionDetail(String conversationId) =>
      'conversations/$conversationId/messages';

  // Message
  static const String sendMessage = 'messages';
  static String editMessage(String messageId) => 'messages/$messageId';
  static String deleteMessage(String messageId) => 'messages/$messageId';

  // Notification
  static const String getNotifications = 'notifications';
  static String markNotificationAsRead(String notificationId) =>
      'notifications/$notificationId/mark-as-read';
  static const String markAllNotificationAsRead =
      'notifications/mark-all-as-read';

  // Report
  static const String getTotalRevenueChart = 'revenues/chart';
  static String getRevenueChartByEventId(String eventId) =>
      'revenues/chart/$eventId';
}

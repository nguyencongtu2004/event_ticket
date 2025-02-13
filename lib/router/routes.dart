class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String buyerHome = '/buyer-home';
  static const String creatorHome = '/creator-home';

  static const String ticket = '/ticket';
  static const String profile = '/profile';
  static const String eventManagement = '/event-management';
  static const String eventManagementFullScreen = '/event-management-full-screen';
  static const String event = '/event';
  static const String checkIn = '/check-in';
  static const String forum = '/forum';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String editProfile = '/edit-profile';

  // Event
  static const String eventDetail = '/event/:eventId';
  static String getEventDetailPath(String eventId) => '/event/$eventId';
  static const String editEvent = '/edit-event/:eventId';
  static String getEditEventPath(String eventId) => '/edit-event/$eventId';
  static const String createEvent = '/create-event';
  static const String searchEvent = '/search-event';
  static const String eventList = '/event-list';
  static const String eventParticipants = '/event-participants';
  static String getEventListPath({required String title, required String sortBy}) => 
      '/event-list?title=$title&sortBy=$sortBy';

  // Ticket
  static const String ticketDetail = '/ticket/:ticketId';
  static String getTicketDetailPath(String ticketId) => '/ticket/$ticketId';
  static const String transferTicketSearch = '/transfer-ticket-search';
  static const String transferTicket = '/transfer-ticket';

  // Forum
  static const String forumDetail = '/forum/:forumId';
  static String getForumDetailPath(String forumId) => '/forum/$forumId';

  // Notification
  static const String notification = '/notification';

  // Admin
  static const String admin = '/admin';
  static const String accountManagement = '/account-management';
  static const String universityManagement = '/university-management';
  static const String facultyManagement = '/faculty-management';
  static const String majorManagement = '/major-management';

  // Report
  static const String report = '/report';
  static const String reportEvent = '/report-event';

}

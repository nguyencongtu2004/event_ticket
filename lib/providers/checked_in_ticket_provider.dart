import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckedInTicketProvider extends AsyncNotifier<List<Ticket>> {
  final _ticketRequest = TicketRequest();
  final List<String> refusedBookingCodes = [];

  @override
  Future<List<Ticket>> build() async {
    return [];
  }

  // Check if a ticket already exists
  bool ticketExists(String bookingCode) {
    return state.value!.any((ticket) => ticket.bookingCode == bookingCode);
  }

  // Check if a ticket is refused
  bool isTicketRefused(String bookingCode) {
    return refusedBookingCodes.contains(bookingCode);
  }

  // Check-in a ticket
  Future<String?> checkInTicket(String bookingCode) async {
    if (ticketExists(bookingCode) || isTicketRefused(bookingCode)) return null;

    final response = await _ticketRequest.checkInTicket(bookingCode);

    if (response.statusCode == 200) {
      final ticket = Ticket.fromJson(response.data as Map<String, dynamic>);
      state = AsyncValue.data([...state.value!, ticket]);
      return 'Check-in successful for ${ticket.buyer?.name}';
    } else if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 403) {
      refusedBookingCodes.add(bookingCode);
      return response.data['message'];
    }

    return null;
  }

  Future<String?> checkInByStudentId(String studentId) async {
    print(studentId);
    final response = await _ticketRequest.checkInTicketByStudentId(studentId);

    if (response.statusCode == 200) {
      final ticket = Ticket.fromJson(response.data as Map<String, dynamic>);
      state = AsyncValue.data([...state.value!, ticket]);
      return 'Check-in successful for ${ticket.buyer?.name}';
    } else if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 403) {
      return response.data['message'];
    }

    return null;
  }
}

final checkedInTicketProvider =
    AsyncNotifierProvider<CheckedInTicketProvider, List<Ticket>>(
        CheckedInTicketProvider.new);

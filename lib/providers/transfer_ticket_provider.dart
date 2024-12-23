import 'package:event_ticket/models/trasfer_ticket.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferTicketNotifier extends AsyncNotifier<List<TransferTicket>> {
  final _ticketRequest = TicketRequest();

  @override
  Future<List<TransferTicket>> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await _ticketRequest.getTransferTicket();
      final transferTickets = (response.data as List)
          .map((e) => TransferTicket.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Trả về vé
      return transferTickets;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in TransferTicketNotifier.build: $e');
      print(st);
      return [];
    }
  }
}

final transferTicketProvider =
    AsyncNotifierProvider<TransferTicketNotifier, List<TransferTicket>>(
        TransferTicketNotifier.new);

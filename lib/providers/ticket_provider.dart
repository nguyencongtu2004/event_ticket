import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketNotifier extends AsyncNotifier<List<Ticket>> {
  final _ticketRequest = TicketRequest();

  @override
  Future<List<Ticket>> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await _ticketRequest.getHistory();
      final tickets = (response.data as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList();

      // Trả về vé
      return tickets;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in TicketNotifier.build: $e');
      print(st);
      return [];
    }
  }
}

final ticketProvider =
    AsyncNotifierProvider<TicketNotifier, List<Ticket>>(TicketNotifier.new);

import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventNotifier extends AsyncNotifier<List<Event>> {
  final _eventRequest = EventRequest();

  @override
  Future<List<Event>> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await _eventRequest.getEvents();
      final events = (response.data as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();

      // Trả về dữ liệu người dùng
      return [...events, ...events, ...events];
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in EventNotifier.build: $e');
      print('Stacktrace: $st');
      return [];
    }
  }
}

final eventProvider =
    AsyncNotifierProvider<EventNotifier, List<Event>>(EventNotifier.new);

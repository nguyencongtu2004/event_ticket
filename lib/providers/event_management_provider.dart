import 'package:dio/dio.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventManagementNotifier extends AsyncNotifier<List<Event>> {
  final _eventRequest = EventRequest();

  @override
  Future<List<Event>> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final user = ref.read(userProvider).value;
      final response = await _eventRequest.getEvents(queryParameters: {
        'createdBy': user?.id,
      });
      final events = (response.data as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();

      // Trả về dữ liệu người dùng
      return events;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in EventNotifier.build: $e');
      print(st);
      return [];
    }
  }

  Future<bool> createEvent(FormData formdata) async {
    try {
      // Gọi API để tạo sự kiện
      final response = await _eventRequest.createEvent(formdata);

      if (response.statusCode != 201) {
        return false;
      }

      // Cập nhật danh sách sự kiện
      state = AsyncValue.data(await build());
      return true;
    } catch (e) {
      print('Error in EventNotifier.createEvent: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      // Gọi API để xóa sự kiện
      final response = await _eventRequest.deleteEvent(eventId);

      if (response.statusCode != 200) {
        return false;
      }
      state = AsyncValue.data(
          state.value!.where((event) => event.id != eventId).toList());

      return true;
    } catch (e) {
      print('Error in EventNotifier.deleteEvent: $e');
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, FormData formdata) async {
    try {
      // Gọi API để cập nhật sự kiện
      final response = await _eventRequest.updateEvent(eventId, formdata);

      if (response.statusCode != 200) {
        return false;
      }

      // Cập nhật danh sách sự kiện
      state = AsyncValue.data(await build());
      return true;
    } catch (e) {
      print('Error in EventNotifier.updateEvent: $e');
      return false;
    }
  }
}

final eventManagementProvider =
    AsyncNotifierProvider<EventManagementNotifier, List<Event>>(
        EventManagementNotifier.new);

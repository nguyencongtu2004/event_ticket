import 'package:dio/dio.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventManagementNotifier extends AsyncNotifier<List<Event>> {
  final _eventRequest = EventRequest();

  @override
  Future<List<Event>> build() async {
    try {
      state = const AsyncValue.loading();
      final response = await _eventRequest.getManagementEvents();
      final events = (response.data as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
      return events;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print('Error in EventManagementNotifier.build: $e');
      print(st);
      return [];
    }
  }

  Future<bool> createEvent(FormData formData) async {
    try {
      final response = await _eventRequest.createEvent(formData);
      if (response.statusCode == 201) {
        state = AsyncValue.data(await build());
        return true;
      }
      return false;
    } catch (e) {
      print('Error in EventManagementNotifier.createEvent: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      final response = await _eventRequest.deleteEvent(eventId);
      if (response.statusCode == 200) {
        state = AsyncValue.data(
          state.value!.where((event) => event.id != eventId).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error in EventManagementNotifier.deleteEvent: $e');
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, FormData formData) async {
    try {
      final response = await _eventRequest.updateEvent(eventId, formData);
      if (response.statusCode == 200) {
        state = AsyncValue.data(await build());
        return true;
      }
      return false;
    } catch (e) {
      print('Error in EventManagementNotifier.updateEvent: $e');
      return false;
    }
  }

  List<Event>? optimisticUpdateOnDelete(String eventId) {
    final previousState = state.value;
    state = AsyncValue.data(
      state.value!.where((event) => event.id != eventId).toList(),
    );
    return previousState;
  }

  void restoreEvent(List<Event>? previousState) {
    // Thêm lại sự kiện đã xóa
    state = AsyncValue.data(previousState ?? []);
  }
}

final eventManagementProvider =
    AsyncNotifierProvider<EventManagementNotifier, List<Event>>(
        EventManagementNotifier.new);

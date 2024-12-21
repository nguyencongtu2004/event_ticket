import 'package:event_ticket/models/conversasion.dart';
import 'package:event_ticket/requests/conversasion_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversasionNotifier extends AsyncNotifier<List<Conversasion>> {
  final _conversasionRequest = ConversasionRequest();

  @override
  Future<List<Conversasion>> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await _conversasionRequest.getConversasions();
      final conversasions = (response.data as List)
          .map((e) => Conversasion.fromJson(e as Map<String, dynamic>))
          .toList();
      print(conversasions);
      // Trả về dữ liệu người dùng
      return conversasions;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in ConversasionNotifier.build: $e');
      print(st);
      return [];
    }
  }
}

final forumProvider =
    AsyncNotifierProvider<ConversasionNotifier, List<Conversasion>>(
        ConversasionNotifier.new);

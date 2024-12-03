import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/models/user.dart';

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await fetchUserFromApi();
      final user = User.fromJson(response);

      // Trả về dữ liệu người dùng
      return user;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchUserFromApi() async {
    // Mô phỏng gọi API
    await Future.delayed(const Duration(seconds: 1)); // Giả lập thời gian tải
    return {
      "userId": "1",
      "email": "user@example.com",
      "role": "ticket_buyer",
      "name": "John Doe",
      "avatar":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Felis_silvestris_silvestris_Luc_Viatour.jpg/160px-Felis_silvestris_silvestris_Luc_Viatour.jpg",
      "birthday": "1990-01-01T00:00:00.000Z",
      "gender": "male",
      "phone": "123456789",
    };
  }
}

final userProvider =
    AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

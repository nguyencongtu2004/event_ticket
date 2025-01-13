import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/models/user.dart';

class UserNotifier extends AsyncNotifier<User?> {
  final _userRequest = UserRequest();

  @override
  Future<User?> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await _userRequest.getUserInfo();
      final user = User.fromJson(response.data);

      // Trả về dữ liệu người dùng
      return user;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in UserNotifier.build: $e');
      print(st);
      return null;
    }
  }

  Future<bool> updateUser(User newUser, Uint8List? imageBytes) async {
    try {
      final formData = FormData.fromMap({
        ...newUser.toJson(),
        if (imageBytes != null)
          'avatar': MultipartFile.fromBytes(
            imageBytes, // Sử dụng dữ liệu nhị phân Uint8List
            filename: 'avatar.png', // Đặt tên tệp
            contentType: DioMediaType('image', 'png'),
          ),
      });

      final response = await _userRequest.updateUserInfo(formData);
      if (response.statusCode != 200) {
        return false;
      }

      // Cập nhật lại trạng thái với user mới từ API
      final updatedUser = User.fromJson(response.data);
      state = AsyncValue.data(updatedUser);

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final userProvider =
    AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

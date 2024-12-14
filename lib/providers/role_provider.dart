import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/enum.dart';

class RoleNotifier extends AsyncNotifier<Roles> {
  @override
  Future<Roles> build() async {
    // Lấy role ban đầu từ AuthService
    return await AuthService.getRole();
  }

  // Hàm để thay đổi role
  Future<void> setRole(Roles newRole) async {
    // Cập nhật state với giá trị role mới
    state = AsyncValue.data(newRole);
  }

  // Hàm reset role về giá trị mặc định từ AuthService
  Future<void> resetRole() async {
    state = const AsyncValue.loading();
    try {
      final defaultRole = await AuthService.getRole();
      state = AsyncValue.data(defaultRole);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final roleProvider =
    AsyncNotifierProvider<RoleNotifier, Roles>(RoleNotifier.new);

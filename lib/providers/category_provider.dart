import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/requests/category_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  final _eventRequest = CategoryRequest();

  @override
  Future<List<Category>> build() async {
    try {
      // Đặt trạng thái đang tải
      state = const AsyncValue.loading();

      // Gọi API để lấy dữ liệu
      final response = await _eventRequest.getCategories();
      final categories = (response.data as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      // Trả về dữ liệu người dùng
      return categories;
    } catch (e, st) {
      // Xử lý lỗi và trả về trạng thái lỗi
      state = AsyncValue.error(e, st);
      print('Error in CategoryNotifier.build: $e');
      print(st);
      return [];
    }
  }
}

final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
        CategoryNotifier.new);

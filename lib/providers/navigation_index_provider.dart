import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationIndexNotifier extends StateNotifier<int> {
  NavigationIndexNotifier() : super(0); // Khởi tạo index mặc định là 0

  void setIndex(int newIndex) {
    state = newIndex;
  }
}

final navigationIndexProvider =
    StateNotifierProvider<NavigationIndexNotifier, int>(
        (ref) => NavigationIndexNotifier());

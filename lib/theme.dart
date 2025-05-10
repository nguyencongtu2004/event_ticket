import 'package:flutter/material.dart';

class AppTheme {
  // Màu chính của ứng dụng
  static const Color primaryColor = Color(0xFFFFC2D1); // Màu hồng pastel
  static const Color secondaryColor = Color(0xFFFF8FAF); // Màu hồng đậm hơn
  static const Color backgroundColor = Color(0xFFFFF0F5); // Màu hồng nhạt

  // Theme sáng
  static ThemeData lightTheme = ThemeData(
    //primaryColor: primaryColor,
    //scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(seedColor: backgroundColor),
  );

  // Theme tối
  static ThemeData darkTheme = ThemeData(
    //primaryColor: primaryColor,
    //scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(seedColor: backgroundColor),
  );
}

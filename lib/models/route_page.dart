import 'package:flutter/material.dart';

class RoutePage {
  const RoutePage(
    this.index,
    this.title,
    this.icon,
    this.selectedIcon,
    this.color,
  );

  final int index;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Color color;
}

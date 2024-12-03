import 'package:flutter/material.dart';

class RoutePage {
  const RoutePage(
    this.index,
    this.route,
    this.title,
    this.icon,
    this.selectedIcon,
    this.color,
  );

  final int index;
  final String route;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Color color;
}

import 'package:event_ticket/models/route_page.dart';
import 'package:event_ticket/pages/event/event_management_screen.dart';
import 'package:event_ticket/pages/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class CreatorHomeScreen extends StatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  int _selectedIndex = 0;

  // Tạo một PageStorageBucket để lưu trạng thái
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<RoutePage> routePages = [
    const RoutePage(
        0, 'Event management', Icons.home_outlined, Icons.home, Colors.teal),
    const RoutePage(1, 'Check in', Icons.airplane_ticket_outlined,
        Icons.airplane_ticket, Colors.cyan),
    const RoutePage(
        2, 'Profile', Icons.person_outlined, Icons.person, Colors.orange),
  ];

  // Các trang cần được bọc trong PageStorage
  late final List<Widget> _pages = [
    PageStorage(
      bucket: _bucket,
      child: const EventManagementScreen(),
    ),
    PageStorage(
      bucket: _bucket,
      child: const EventManagementScreen(),
    ),
    PageStorage(
      bucket: _bucket,
      child: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 60,
        indicatorColor: routePages[_selectedIndex].color.withValues(alpha: 0.1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: routePages.map(_buildNavigationDestination).toList(),
      ),
    );
  }

  /// Xây dựng NavigationDestination từ `RoutePage`
  NavigationDestination _buildNavigationDestination(RoutePage routePage) {
    return NavigationDestination(
      icon: Icon(routePage.icon, color: routePage.color, size: 35),
      label: routePage.title,
      selectedIcon:
          Icon(routePage.selectedIcon, color: routePage.color, size: 35),
      tooltip: routePage.title,
    );
  }
}

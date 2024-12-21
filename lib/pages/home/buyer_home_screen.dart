import 'package:event_ticket/models/route_page.dart';
import 'package:event_ticket/pages/event/event_screen.dart';
import 'package:event_ticket/pages/profile/profile_screen.dart';
import 'package:event_ticket/pages/ticket/ticket_screen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BuyerHomeScreen extends StatefulWidget {
  BuyerHomeScreen({super.key, this.index = 0});

  int index;

  @override
  createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  // Tạo một PageStorageBucket để lưu trạng thái
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<RoutePage> routePages = [
    const RoutePage(0, 'Home', Icons.home_outlined, Icons.home, Colors.teal),
    const RoutePage(1, 'Ticket', Icons.airplane_ticket_outlined,
        Icons.airplane_ticket, Colors.cyan),
    const RoutePage(
        2, 'Profile', Icons.person_outlined, Icons.person, Colors.orange),
  ];

  // Các trang cần được bọc trong PageStorage
  late final List<Widget> _pages = [
    PageStorage(
      bucket: _bucket,
      child: const EventScreen(),
    ),
    PageStorage(
      bucket: _bucket,
      child: const TicketScreen(),
    ),
    PageStorage(
      bucket: _bucket,
      child: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[widget.index],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 60,
        indicatorColor: routePages[widget.index].color.withValues(alpha: 0.1),
        selectedIndex: widget.index,
        onDestinationSelected: (index) {
          setState(() {
            widget.index = index;
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

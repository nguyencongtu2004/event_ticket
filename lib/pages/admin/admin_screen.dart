import 'package:event_ticket/pages/admin/management/account_management.dart';
import 'package:event_ticket/pages/admin/management/university_management.dart';
import 'package:event_ticket/pages/event/event_management_screen.dart';
import 'package:event_ticket/pages/report/report_screen.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  static final List<_AdminMenuItem> menuItems = [
    _AdminMenuItem(
      icon: Icons.person,
      title: 'Account Management',
      subtitle: 'Manage user accounts',
      route: Routes.accountManagement,
      builder: (_) => const AccountManagementScreen(),
    ),
    _AdminMenuItem(
      icon: Icons.school,
      title: 'University Management',
      subtitle: 'Manage universities',
      route: Routes.universityManagement,
      builder: (_) => const UniversityManagementScreen(),
    ),
    _AdminMenuItem(
      icon: Icons.event,
      title: 'Event Management',
      subtitle: 'Manage events',
      route: Routes.eventManagementFullScreen,
      builder: (_) => const EventManagementScreen(),
    ),
    _AdminMenuItem(
      icon: Icons.stacked_line_chart_rounded,
      title: 'Report',
      subtitle: 'View reports',
      route: Routes.report,
      builder: (_) => const ReportScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Admin',
      body: LayoutBuilder(builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        if (isLargeScreen) {
          return Row(
            children: [
              Container(
                width: 250,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: menuItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == _selectedIndex;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(item.icon,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.black),
                            const SizedBox(width: 16),
                            Text(
                              item.title,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: menuItems[_selectedIndex].builder(context),
              ),
            ],
          );
        }
        return ListView(
          children: menuItems
              .map((item) => _buildAdminMenuTile(context, item))
              .toList(),
        );
      }),
    );
  }

  Widget _buildAdminMenuTile(BuildContext context, _AdminMenuItem item) {
    return ListTile(
      leading: Icon(item.icon),
      trailing: const Icon(Icons.chevron_right),
      title: Text(
        item.title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(item.subtitle),
      onTap: () => context.push(item.route),
    ).py(8);
  }
}

class _AdminMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final WidgetBuilder builder;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.builder,
  });
}

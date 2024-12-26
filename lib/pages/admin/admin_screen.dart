import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Admin',
      body: ListView(
        children: _buildAdminMenuItems(context),
      ),
    );
  }

  List<Widget> _buildAdminMenuItems(BuildContext context) {
    final menuItems = [
      const _AdminMenuItem(
        icon: Icons.person,
        title: 'Account Management',
        subtitle: 'Manage user accounts',
        route: Routes.accountManagement,
      ),
      const _AdminMenuItem(
        icon: Icons.school,
        title: 'University Management',
        subtitle: 'Manage universities',
        route: Routes.universityManagement,
      ),
      const _AdminMenuItem(
        icon: Icons.event,
        title: 'Event Management',
        subtitle: 'Manage events',
        route: Routes.eventManagementFullScreen,
      ),
      const _AdminMenuItem(
        icon: Icons.stacked_line_chart_rounded,
        title: 'Report',
        subtitle: 'View reports',
        route: Routes.report,
      ),
    ];

    return menuItems.map((item) => _buildAdminMenuCard(context, item)).toList();
  }

  Widget _buildAdminMenuCard(BuildContext context, _AdminMenuItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
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
      ).py(8),
    );
  }
}

class _AdminMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

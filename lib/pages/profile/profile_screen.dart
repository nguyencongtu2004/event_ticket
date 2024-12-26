import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/pages/profile/widget/user_info.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/service/firebase_service.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> onLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.deleteFCMTokenOnServer();
      await AuthService.removeAuthBearerToken();
      await AuthService.removeRole();
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return TicketScaffold(
      title: 'My Profile',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.push(Routes.editProfile),
          tooltip: 'Edit profile',
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userProvider.future),
        child: ListView(
          children: [
            switch (userAsyncValue) {
              AsyncValue<User?>(:final valueOrNull?) => Column(
                  children: [
                    UserInfo(user: valueOrNull).pOnly(bottom: 24),
                    _buildDetailSection(context, valueOrNull),
                    ElevatedButton.icon(
                      onPressed: () => onLogout(context, ref),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ).py(24),
                  ],
                ).wFull(context).pOnly(top: 24),
              AsyncValue(:final error?) => Center(child: Text('Error: $error')),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            context: context,
            icon: Icons.phone,
            label: 'Phone',
            value: user.phone ?? 'Not provided',
          ),
          _buildDetailRow(
            context: context,
            icon: Icons.cake,
            label: 'Birthday',
            value: user.birthday != null
                ? DateFormat('dd/MM/yyyy').format(user.birthday!)
                : 'Not provided',
          ),
          _buildDetailRow(
            context: context,
            icon: Icons.school,
            label: 'University',
            value: user.university?.name ?? 'Not specified',
          ),
          _buildDetailRow(
            context: context,
            icon: Icons.category,
            label: 'Faculty',
            value: user.faculty?.name ?? 'Not specified',
          ),
          _buildDetailRow(
            context: context,
            icon: Icons.badge,
            label: 'Student ID',
            value: user.studentId ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ).expand(),
        ],
      ),
    );
  }
}

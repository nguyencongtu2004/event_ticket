import 'package:event_ticket/pages/profile/widget/user_info.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void onLogout(BuildContext context, WidgetRef ref) {
    AuthService.removeAuthBearerToken();
    AuthService.removeRole();
    context.go(Routes.login);
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
        ),
      ],
      body: userAsyncValue.when(
        data: (user) => Column(
          children: [
            if (user != null)
              UserInfo(user: user)
            else
              const Center(child: Text('No information.')),
            ElevatedButton(
              onPressed: () => onLogout(context, ref),
              child: const Text('Logout'),
            ).pOnly(top: 24),
          ],
        ).wFull(context).pOnly(top: 24),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Đã xảy ra lỗi: $error'),
        ),
      ),
    );
  }
}

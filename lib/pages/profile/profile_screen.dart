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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> onLogout(BuildContext context, WidgetRef ref) async {
    await FirebaseService.deleteFCMTokenOnServer();
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
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userProvider.future),
        child: ListView(
          children: [
            switch (userAsyncValue) {
              // Nếu có dữ liệu, hiển thị dữ liệu, kể cả trong lúc làm mới.
              AsyncValue<User?>(:final valueOrNull?) => Column(
                  children: [
                    UserInfo(user: valueOrNull),
                    ElevatedButton(
                      onPressed: () => onLogout(context, ref),
                      child: const Text('Logout'),
                    ).pOnly(top: 24),
                  ],
                ).wFull(context).pOnly(top: 24),
              // Nếu có lỗi, hiển thị lỗi.
              AsyncValue(:final error?) => Center(child: Text('Error: $error')),
              // Nếu không có dữ liệu, hiển thị trạng thái tải.
              _ => const Center(child: CircularProgressIndicator()),
            },
          ],
        ),
      ),
    );
  }
}

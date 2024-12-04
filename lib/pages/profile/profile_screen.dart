import 'package:event_ticket/pages/profile/widget/user_info.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return TicketScaffold(
      title: 'My Profile',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.push('/edit-profile'),
        ),
      ],
      body: userAsyncValue.when(
        data: (user) => user != null
            ? Column(
                children: [
                  UserInfo(user: user),
                ],
              ).wFull(context).pOnly(top: 24)
            : const Center(child: Text('Không có thông tin người dùng.')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Đã xảy ra lỗi: $error'),
        ),
      ),
    );
  }
}

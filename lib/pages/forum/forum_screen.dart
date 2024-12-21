import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/models/conversasion.dart';
import 'package:event_ticket/providers/forum_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  void onConversasionTap(BuildContext context, Conversasion conversasion) {
    context.push(Routes.getForumDetailPath(conversasion.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(forumProvider);
    return TicketScaffold(
      title: 'Forum',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(forumProvider.future),
        child: switch (asyncValue) {
          // Nếu có dữ liệu, hiển thị dữ liệu.
          AsyncValue<List<Conversasion>>(:final valueOrNull?) =>
            _buildConversasionList(context, ref, valueOrNull),
          // Nếu có lỗi, hiển thị lỗi.
          AsyncValue(:final error?) => Center(child: Text('Error: $error')),
          // Nếu không có dữ liệu, hiển thị trạng thái tải.
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _buildConversasionList(
      BuildContext context, WidgetRef ref, List<Conversasion>? conversations) {
    if (conversations == null || conversations.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final item = conversations[index];
        return ListTile(
          onTap: () => onConversasionTap(context, item),
          title: Text(item.title ?? 'No title'),
          subtitle: Text(item.createdAt?.toFullDate() ?? ''),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: const Center(
            child: Text('No conversations.'),
          ),
        ),
      ],
    );
  }
}

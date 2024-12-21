import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumDetailScreen extends ConsumerStatefulWidget {
  const ForumDetailScreen({
    super.key,
    required this.forumId,
  });

  final String forumId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForumDetailScreenState();
}

class _ForumDetailScreenState extends ConsumerState<ForumDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Forum Detail',
      body: Text(widget.forumId),
    );
  }
}

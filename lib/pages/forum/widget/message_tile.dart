import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/models/message.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:velocity_x/velocity_x.dart';

class MessageTile extends ConsumerWidget {
  const MessageTile({
    super.key,
    required this.message,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  final Message message;
  final VoidCallback? onReply;
  final Function(String)? onEdit;
  final VoidCallback? onDelete;

  void showOptionLongPress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit message
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Message'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  final controller =
                      TextEditingController(text: message.content);
                  return AlertDialog(
                    title: const Text('Edit Message'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter new message',
                      ),
                      maxLines: null,
                    ),
                    actions: [
                      // Cancel
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),

                      // Save
                      TextButton(
                        onPressed: () {
                          if (onEdit != null) {
                            onEdit!(controller.text);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // Delete message
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Message',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              if (onDelete != null) onDelete!();
            },
          ),
        ],
      ).p(12),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider).value;
    return GestureDetector(
      onLongPress: () {
        if (user?.id == null ||
            message.sender?.id == null ||
            message.isDeleted!) return;
        if (user!.id == message.sender!.id) {
          showOptionLongPress(context);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Avatar(message.sender, radius: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender?.name ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.content ?? 'No content',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  ],
                ),
              ),

              // time
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    message.time?.toTimeAgo() ?? '',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Reply',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                  ).onInkTap(onReply),
                  if (message.isEdited ?? false) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Edited',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ]
                ],
              ),
            ],
          ).expand(),
        ],
      ),
    );
  }
}

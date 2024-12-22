import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/models/message.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:flutter/material.dart';

import 'package:velocity_x/velocity_x.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    this.onReply,
    this.onLongPress,
  });

  final Message message;
  final VoidCallback? onReply;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            ).onLongPress(onLongPress, key),

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
              ],
            ),
          ],
        ).expand(),
      ],
    );
  }
}

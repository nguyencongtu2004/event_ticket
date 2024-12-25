import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/conversasion.dart';
import 'package:event_ticket/models/message.dart';
import 'package:event_ticket/pages/forum/widget/message_tile.dart';
import 'package:event_ticket/requests/conversasion_request.dart';
import 'package:event_ticket/requests/message_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ForumDetailScreen extends StatefulWidget {
  const ForumDetailScreen({
    super.key,
    required this.forumId,
    this.conversasion,
  });

  final String forumId;
  final Conversasion? conversasion;

  @override
  State<StatefulWidget> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  List<Message> messages = [];
  final _conversasionRequest = ConversasionRequest();
  final _messageRequest = MessageRequest();
  int page = 1;
  int limit = 10;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  Message? replyingMessage;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    getMessages();

    // Load more messages when scrolling to the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading && hasMore) {
          getMessages(page: page + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> getMessages({int page = 1, int limit = 10}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final response = await _conversasionRequest
        .getConversasionDetail(widget.forumId, page: page, limit: limit);
    if (response.statusCode == 200) {
      final newMessages = List<Message>.from((response.data as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>)));

      setState(() {
        if (page == 1) {
          messages = newMessages;
        } else {
          messages.addAll(newMessages);
        }
        this.page = page;
        hasMore = newMessages.length >= limit;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      context.showAnimatedToast(response.data['message']);
    }
  }

  void onSend() async {
    final message = _messageController.text;
    if (message.isEmpty) return;
    setState(() {
      isSending = true;
    });
    final response = await _messageRequest.sendMessage(
      widget.forumId,
      message,
      replyingMessage?.id,
    );
    setState(() {
      isSending = false;
    });
    if (response.statusCode == 201) {
      final newMessage =
          Message.fromJson(response.data as Map<String, dynamic>);

      // Scroll to top when sending a new message (not when replying)
      if (replyingMessage?.id == null) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      _messageController.clear();
      setState(() {
        messages = [newMessage, ...messages];
        replyingMessage = null;
      });
    } else {
      context.showAnimatedToast(response.data['message']);
    }
  }

  void onReply(Message message) {
    print('Reply to message: ${message.sender?.name}');
    // _messageFocusNode.requestFocus();
    setState(() {
      replyingMessage = message;
    });
  }

  Future<void> onEditMessage(String messageId, String newContent) async {
    final response = await _messageRequest.editMessage(messageId, newContent);
    if (response.statusCode == 200) {
      setState(() {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            content: newContent,
            isEdited: true,
            isDeleted: false,
          );
        }
      });
    } else {
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  Future<void> onDeleteMessage(String messageId) async {
    final response = await _messageRequest.deleteMessage(messageId);
    if (response.statusCode == 200) {
      setState(() {
        messages.removeWhere((m) => m.id == messageId);
      });
    } else {
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: widget.conversasion?.title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Messages
          RefreshIndicator(
            onRefresh: () => getMessages(page: 1),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const CircularProgressIndicator().centered();
                }

                final message = messages[index];
                // Chỉ hiển thị tin nhắn gốc (không có parentMessageId)
                if (message.parentMessageId != null) {
                  return const SizedBox.shrink();
                }

                return _buildMessageTree(message);
              },
            ),
          ).expand(),

          // Input message
          Column(
            children: [
              if (replyingMessage != null)
                Row(
                  spacing: 4,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Replying to '),
                          TextSpan(
                            text: '${replyingMessage?.sender?.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '... '),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => setState(() => replyingMessage = null),
                      tooltip: 'Cancel reply',
                    ),
                  ],
                ),
              Row(
                spacing: 4,
                children: [
                  TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(24))),
                      isDense: true,
                      hintText: 'Type your message here...',
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHigh
                          .withValues(alpha: 0.5),
                      filled: true,
                    ),
                  ).expand(),
                  if (isSending)
                    const CircularProgressIndicator().wh(24, 24).p(12)
                  else
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => onSend(),
                      tooltip: 'Send message',
                    ),
                ],
              ),
            ],
          ).pOnly(bottom: 16, top: 4),
        ],
      ).px(16),
    );
  }

  // Hàm đệ quy để lấy tất cả tin nhắn con
  List<Message> _getChildMessages(String parentId) {
    return messages.where((m) => m.parentMessageId == parentId).toList();
  }

  // Hàm đệ quy để hiển thị tin nhắn và các tin nhắn con
  Widget _buildMessageTree(Message message,
      {double leftPadding = 0, bool isLastChild = true}) {
    final childMessages = _getChildMessages(message.id);

    if (message.isDeleted! && childMessages.isEmpty) {
      return const SizedBox(width: double.infinity);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageTile(
          key: ValueKey(message.id),
          message: message,
          onReply: () => onReply(message),
          onEdit: (newContent) => onEditMessage(message.id, newContent),
          onDelete: () => onDeleteMessage(message.id),
        ),
        if (childMessages.isNotEmpty)
          Container(
            // Giảm padding để đường kẻ gần với avatar hơn
            padding: EdgeInsets.only(left: leftPadding + 20),
            child: Stack(
              clipBehavior: Clip.none, // Cho phép vẽ ra ngoài container
              children: [
                // Vẽ đường kết nối
                Positioned(
                  // Điều chỉnh vị trí để đường kẻ bắt đầu từ avatar
                  left: 20,
                  // Điều chỉnh để đường kẻ bắt đầu từ avatar message trước
                  top: 20,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
                Column(
                  children: childMessages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final childMessage = entry.value;
                    final isLast = index == childMessages.length - 1;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Đường ngang nối với avatar
                        Positioned(
                          left: 0,
                          top: 24, // Căn chỉnh với avatar của message
                          child: Container(
                            width: 50, // Độ dài đường ngang
                            height: 2,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                        _buildMessageTree(
                          childMessage,
                          leftPadding: 16,
                          isLastChild: isLast,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    ).py(4); // Giảm khoảng cách giữa các message
  }
}

// Custom painter for thread connections (ngâm cứu sau)
class ThreadConnectionPainter extends CustomPainter {
  final int childCount;
  final bool isLastThread;

  ThreadConnectionPainter({
    required this.childCount,
    required this.isLastThread,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double spacing = size.height / childCount;
    const double radius = 8.0;

    for (var i = 0; i < childCount; i++) {
      final double startY =
          i * spacing + 20; // 20 is offset to align with avatar

      final path = Path();

      // Starting point (from parent avatar)
      path.moveTo(0, startY);

      // Draw horizontal line with curved corners
      path.lineTo(radius, startY);

      // Draw curved line to the child avatar
      path.arcToPoint(
        Offset(20, startY),
        radius: const Radius.circular(radius),
        clockwise: true,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ThreadConnectionPainter oldDelegate) =>
      oldDelegate.childCount != childCount ||
      oldDelegate.isLastThread != isLastThread;
}

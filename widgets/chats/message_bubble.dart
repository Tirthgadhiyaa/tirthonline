// lib/chat/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../../models/chat_message_model.dart';
import '../../screens/seller/chat_panel/theme/chat_theme.dart';
import 'attachment_viewer.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showStatus;
  final bool isNew;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.showStatus = false,
    this.isNew = false,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    if (widget.isNew) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatTheme = ChatThemeProvider.of(context);

    final bubbleColor =
        widget.isMe ? chatTheme.userBubbleColor : chatTheme.otherBubbleColor;

    final textColor =
        widget.isMe ? chatTheme.userTextColor : chatTheme.otherTextColor;

    final borderRadius = widget.isMe
        ? chatTheme.userBubbleBorderRadius
        : chatTheme.otherBubbleBorderRadius;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment:
                widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              boxShadow: [chatTheme.bubbleShadow],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius,
                onLongPress: () {
                  // Show options like copy, delete, etc.
                  _showMessageOptions(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Attachments
                      if (widget.message.attachments.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildAttachments(context),
                        ),

                      // Message text
                      if (widget.message.content.isNotEmpty)
                        Text(
                          widget.message.content,
                          style: chatTheme.messageTextStyle.copyWith(
                            color: textColor,
                          ),
                        ),

                      // Time and read status
                      if (widget.showStatus)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('h:mm a')
                                    .format(widget.message.createdAt),
                                style: chatTheme.timeTextStyle.copyWith(
                                  color: widget.isMe
                                      ? chatTheme.userTextColor.withOpacity(0.7)
                                      : chatTheme.otherTextColor
                                          .withOpacity(0.7),
                                ),
                              ),
                              if (widget.isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  widget.message.isRead
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 12,
                                  color: widget.message.isRead
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    final attachments = widget.message.attachments;

    if (attachments.length == 1) {
      return AttachmentViewer(attachment: attachments.first);
    }

    // Grid layout for multiple attachments
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        return AttachmentViewer(attachment: attachments[index]);
      },
    );
  }

  void _showMessageOptions(BuildContext context) {
    final chatTheme = ChatThemeProvider.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  // Copy message to clipboard
                  Navigator.pop(context);
                },
              ),
              if (widget.isMe)
                ListTile(
                  leading: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Delete',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  onTap: () {
                    // Delete message
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

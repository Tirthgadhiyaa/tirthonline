// lib/chat/widgets/chat_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chat_bloc/chat_bloc.dart';
import '../../bloc/chat_bloc/chat_state.dart';


class ChatBadge extends StatelessWidget {
  final Widget child;
  final double top;
  final double right;
  final double badgeSize;

  const ChatBadge({
    Key? key,
    required this.child,
    this.top = -5,
    this.right = -5,
    this.badgeSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) => current is UnreadCountsLoaded,
      builder: (context, state) {
        int totalUnread = 0;
        
        if (state is UnreadCountsLoaded) {
          totalUnread = state.total;
        }
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (totalUnread > 0)
              Positioned(
                top: top,
                right: right,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(badgeSize / 2),
                  ),
                  constraints: BoxConstraints(
                    minWidth: badgeSize,
                    minHeight: badgeSize,
                  ),
                  child: Center(
                    child: Text(
                      totalUnread > 99 ? '99+' : totalUnread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

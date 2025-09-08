// lib/chat/theme/chat_theme.dart

import 'package:flutter/material.dart';

class ChatTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color userBubbleColor;
  final Color otherBubbleColor;
  final Color userTextColor;
  final Color otherTextColor;
  final TextStyle messageTextStyle;
  final TextStyle timeTextStyle;
  final BorderRadius userBubbleBorderRadius;
  final BorderRadius otherBubbleBorderRadius;
  final BoxShadow bubbleShadow;
  final Duration animationDuration;

  const ChatTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.userBubbleColor,
    required this.otherBubbleColor,
    required this.userTextColor,
    required this.otherTextColor,
    required this.messageTextStyle,
    required this.timeTextStyle,
    required this.userBubbleBorderRadius,
    required this.otherBubbleBorderRadius,
    required this.bubbleShadow,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  factory ChatTheme.fromColorScheme(ColorScheme colorScheme) {
    return ChatTheme(
      primaryColor: colorScheme.primary,
      secondaryColor: colorScheme.secondary,
      backgroundColor: colorScheme.surface,
      userBubbleColor: colorScheme.primary,
      otherBubbleColor: colorScheme.surfaceVariant,
      userTextColor: colorScheme.onPrimary,
      otherTextColor: colorScheme.onSurfaceVariant,
      messageTextStyle: const TextStyle(fontSize: 16, height: 1.4),
      timeTextStyle: TextStyle(
          fontSize: 10, color: colorScheme.onSurface.withOpacity(0.6)),
      userBubbleBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      ),
      otherBubbleBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(16),
      ),
      bubbleShadow: BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    );
  }
}

class ChatThemeProvider extends InheritedWidget {
  final ChatTheme chatTheme;

  const ChatThemeProvider({
    Key? key,
    required this.chatTheme,
    required Widget child,
  }) : super(key: key, child: child);

  static ChatTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ChatThemeProvider>();
    return provider?.chatTheme ??
        ChatTheme.fromColorScheme(Theme.of(context).colorScheme);
  }

  @override
  bool updateShouldNotify(ChatThemeProvider oldWidget) {
    return chatTheme != oldWidget.chatTheme;
  }
}

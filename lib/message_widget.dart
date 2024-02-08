import 'package:flutter/material.dart';
import 'package:jarvis/mistral.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MessageData {
  final Role role;
  String content;

  MessageData({required this.role, required this.content});
}

class MessageView extends StatelessWidget {
  final MessageData message;
  const MessageView({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.role == Role.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: MarkdownBlock(
              data: message.content,
              selectable: true,
            ),
          ),
        ),
      ),
    );
  }
}

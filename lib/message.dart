import 'package:flutter/material.dart';

class MessageData {
  final bool fromClient;
  final String mistralResponse;

  MessageData({required this.mistralResponse, required this.fromClient});
}

class MessageView extends StatelessWidget {
  final String data;
  const MessageView({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 32, 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(data),
          ),
        ),
      ),
    );
  }
}

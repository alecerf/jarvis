import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jarvis/message_widget.dart';
import 'package:jarvis/mistral.dart';
import 'package:jarvis/settings.dart';

class MessageForm extends StatelessWidget {
  final Function(MessageData, String) callback;
  final Function() cleanCallback;
  final Iterable<MessageData> history;

  MessageForm({
    super.key,
    required this.callback,
    required this.cleanCallback,
    required this.history,
  });

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  void submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      String content = _messageController.text;
      _messageController.clear();
      callback(
        MessageData(role: Role.user, content: content),
        UniqueKey().toString(),
      );
      MistralQuery query = MistralQuery(
        apiKey: SettingsDataWidget.of(context).apiKey,
        model: SettingsDataWidget.of(context).model,
      );
      ask(query, history).then((response) {
        response.stream.transform(utf8.decoder).listen((value) {
          int firstNewline;
          while ((firstNewline = value.indexOf('\n')) != -1) {
            String chunkLine = value.substring(0, firstNewline);
            value = value.substring(firstNewline + 1);
            if (chunkLine.startsWith('data:')) {
              var json = chunkLine.substring(6).trim();
              if (json != '[DONE]') {
                MistralResponse response =
                    MistralResponse.fromJson(jsonDecode(json));
                callback(
                  MessageData(
                    role: Role.assistant,
                    content: response.choices.first.delta.content,
                  ),
                  response.id,
                );
              }
            }
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FloatingActionButton.extended(
                onPressed: () => cleanCallback(),
                label: const Icon(Icons.cleaning_services),
                shape: const CircleBorder(),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                onFieldSubmitted: (_) => submit(context),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter your message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _messageController.clear(),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

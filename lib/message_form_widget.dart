import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jarvis/api_key_widget.dart';
import 'package:jarvis/mistral.dart';

class MessageForm extends StatelessWidget {
  final Function(String?, String?, String) callback;

  MessageForm({required this.callback, super.key});

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  void submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      String message = _messageController.text;
      _messageController.clear();
      callback(message, null, UniqueKey().toString());
      ask(message, ApiKeyWidget.of(context).apiKey).then((response) {
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
                    null,
                    utf8.decode(response.choices.first.delta.content.codeUnits),
                    response.id);
              }
            }
          }
        });
      }).catchError(
        (error) {
          callback(error, null, UniqueKey().toString());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: <Widget>[
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
    );
  }
}

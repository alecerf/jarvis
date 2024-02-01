import 'package:flutter/material.dart';
import 'package:jarvis/api_key_widget.dart';
import 'package:jarvis/mistral.dart';

class MessageForm extends StatelessWidget {
  final Function(String, bool) callback;

  MessageForm({required this.callback, super.key});

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  void submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      callback(_messageController.text, true);
      _messageController.clear();
      ask(_messageController.text, ApiKeyWidget.of(context).apiKey)
          .then((value) {
        callback(value.body, false);
      }).catchError(
        (error) {
          callback(error, false);
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => submit(context),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

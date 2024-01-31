import 'package:flutter/material.dart';
import 'package:jarvis/mistral.dart';

class MessageForm extends StatefulWidget {
  final Function(String, bool) callback;
  final String apiKey;

  const MessageForm({required this.callback, required this.apiKey, super.key});

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      final response = ask(messageController.text, widget.apiKey);
      widget.callback(messageController.text, true);
      messageController.clear();
      response.then((value) {
        widget.callback(value.body, false);
      }).catchError(
        (error) {
          widget.callback(error, false);
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
              controller: messageController,
              onFieldSubmitted: (_) => submit(),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter a message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => messageController.clear(),
                  )),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'You forgot something';
                }
                if (widget.apiKey.isEmpty) {
                  return 'No apikey';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => submit(),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

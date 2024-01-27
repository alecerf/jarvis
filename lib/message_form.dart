import 'package:flutter/material.dart';
import 'package:jarvis/mistral.dart';

class MessageForm extends StatefulWidget {
  final Function(String, bool) callback;
  final String apiKey;

  const MessageForm(this.callback, this.apiKey, {super.key});

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: messageController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a message',
                  suffixIcon: Icon(Icons.clear)),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'You forgot something';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
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
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

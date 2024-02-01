import 'package:flutter/material.dart';

class ApiKeyForm extends StatelessWidget {
  ApiKeyForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  void save(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: const Text('Setup'),
        content: TextFormField(
          controller: _controller,
          maxLines: 1,
          obscureText: true,
          onFieldSubmitted: (_) => save(context),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter your Mistral API key',
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'API key is required';
            }
            return null;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => save(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

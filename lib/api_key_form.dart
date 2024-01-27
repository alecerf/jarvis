import 'package:flutter/material.dart';

class ApiKeyForm extends StatefulWidget {
  final Function(String) callback;

  const ApiKeyForm(this.callback, {super.key});

  @override
  State<ApiKeyForm> createState() => _ApiKeyFormState();
}

class _ApiKeyFormState extends State<ApiKeyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: const Text('Setup Mistral API Key'),
        content: TextFormField(
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'You forgot something';
            }
            return null;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.callback(controller.text);
                controller.clear();
                return Navigator.pop(context, 'Setup');
              }
            },
            child: const Text('Setup'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ApiKeyForm extends StatelessWidget {
  const ApiKeyForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: AlertDialog(
        title: const Text('Mistral API key'),
        content: TextFormField(
          controller: controller,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'API key is required';
            }
            return null;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                return Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

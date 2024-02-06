import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late ScaffoldMessengerState snackbar;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      _controller.text = prefs.getString('key') ?? "";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter your Mistral API key',
                  suffixIcon: InkWell(
                    child: const Icon(Icons.clear),
                    onTap: () {
                      _controller.clear();
                    },
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'API key is required';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _prefs.then((SharedPreferences prefs) {
                        prefs.setString('key', _controller.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your settings have been saved'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    snackbar.clearSnackBars();
    super.dispose();
  }
}

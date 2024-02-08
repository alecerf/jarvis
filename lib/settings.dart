import 'package:flutter/material.dart';
import 'package:jarvis/mistral.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDataWidget extends InheritedWidget {
  final String apiKey;
  final String model;

  const SettingsDataWidget({
    super.key,
    required this.apiKey,
    required this.model,
    required super.child,
  });

  @override
  bool updateShouldNotify(SettingsDataWidget oldWidget) {
    return apiKey != oldWidget.apiKey;
  }

  static SettingsDataWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsDataWidget>()!;
  }
}

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
  Model? _model = Model.tiny;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      _controller.text = prefs.getString('key') ?? "";
      _model = Model.values.firstWhere(
          (element) => element.name == (prefs.getString('model') ?? 'tiny'));
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Divider(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Models',
                        style: TextStyle(
                          fontSize: 18,
                        )),
                  ),
                  ListTile(
                    title: const Text('Tiny'),
                    leading: Radio<Model>(
                      value: Model.tiny,
                      groupValue: _model,
                      onChanged: (Model? value) {
                        setState(() {
                          _model = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Small'),
                    leading: Radio<Model>(
                      value: Model.small,
                      groupValue: _model,
                      onChanged: (Model? value) {
                        setState(() {
                          _model = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Medium'),
                    leading: Radio<Model>(
                      value: Model.medium,
                      groupValue: _model,
                      onChanged: (Model? value) {
                        setState(() {
                          _model = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _prefs.then((SharedPreferences prefs) {
                        prefs.setString('key', _controller.text);
                        prefs.setString('model', _model!.name);
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

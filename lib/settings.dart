import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jarvis/mistral.dart';

class SettingsData extends InheritedWidget {
  final String apiKey;
  final String model;
  final double temperature;
  final double topp;

  const SettingsData({
    super.key,
    required this.apiKey,
    required this.model,
    required this.temperature,
    required this.topp,
    required super.child,
  });

  @override
  bool updateShouldNotify(SettingsData oldWidget) {
    return apiKey != oldWidget.apiKey;
  }

  static SettingsData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsData>()!;
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _toppController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late ScaffoldMessengerState snackbar;
  Model? _model = Model.tiny;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      _apiKeyController.text = prefs.getString('key') ?? "";
      _temperatureController.text =
          (prefs.getDouble('temperature') ?? 0.7).toString();
      _toppController.text = (prefs.getDouble('top_p') ?? 1).toString();
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            TextFormField(
              controller: _apiKeyController,
              maxLines: 1,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Enter your Mistral API key',
                suffixIcon: InkWell(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    _apiKeyController.clear();
                  },
                ),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Field is required';
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Divider(),
            ),
            TextFormField(
              controller: _temperatureController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              ],
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a temperature sampling',
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Field is required';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) < 0 ||
                    double.parse(value) > 1) {
                  return 'Field should be in range [0..1]';
                }
                return null;
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Divider(),
            ),
            TextFormField(
              controller: _toppController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              ],
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a nucleus sampling',
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Field is required';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) < 0 ||
                    double.parse(value) > 1) {
                  return 'Field should be in range [0..1]';
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
                      prefs.setString('key', _apiKeyController.text);
                      prefs.setDouble('temperature',
                          double.parse(_temperatureController.text));
                      prefs.setDouble(
                          'top_p', double.parse(_toppController.text));
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jarvis/message_form_widget.dart';
import 'package:jarvis/message_widget.dart';
import 'package:jarvis/mistral.dart';
import 'package:jarvis/settings.dart';

void main() {
  runApp(const Jarvis());
}

class Jarvis extends StatelessWidget {
  const Jarvis({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _apiKey = "";
  String _model = "";

  double _temperature = 0;
  double _topp = 0;

  final Map<String, MessageData> _history = <String, MessageData>{};
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void updateMessages(MessageData data, String id) {
    setState(() {
      _history.update(
        id,
        (value) {
          _history[id]!.content = _history[id]!.content + data.content;
          return _history[id]!;
        },
        ifAbsent: () {
          return data;
        },
      );
    });
  }

  void clean() {
    setState(() {
      _history.clear();
    });
  }

  void loadConfiguration() {
    _prefs.then((SharedPreferences prefs) {
      _apiKey = prefs.getString('key') ?? "";
      _temperature = prefs.getDouble('temperature') ?? 0.7;
      _topp = prefs.getDouble('top_p') ?? 1;
      _model = prefs.getString('model') ?? Model.tiny.name;
      if (_apiKey.isNotEmpty) {
        setState(() {});
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsView()),
      ).then((value) {
        loadConfiguration();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Jarvis"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Change settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              ).then((value) {
                loadConfiguration();
              });
            },
          ),
        ],
      ),
      body: SettingsData(
        apiKey: _apiKey,
        model: _model,
        temperature: _temperature,
        topp: _topp,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _history.length,
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    return MessageView(
                      message: _history.values
                          .elementAt(_history.values.length - index - 1),
                    );
                  }),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MessageForm(
                  callback: updateMessages,
                  cleanCallback: clean,
                  history: _history.values,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

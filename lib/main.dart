import 'package:flutter/material.dart';
import 'package:jarvis/message_form_widget.dart';
import 'package:jarvis/message_widget.dart';
import 'package:jarvis/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Map<String, MessageData> _responses = <String, MessageData>{};
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void updateMessages(String? userInput, String? response, String id) {
    setState(() {
      _responses.update(
        id,
        (value) {
          _responses[id]!.response = _responses[id]!.response! + response!;
          return _responses[id]!;
        },
        ifAbsent: () {
          return MessageData(userInput: userInput, response: response);
        },
      );
    });
  }

  void loadConfiguration() {
    _prefs.then((SharedPreferences prefs) {
      _apiKey = prefs.getString('key') ?? "";
      _model = prefs.getString('model') ?? Model.tiny.name;
      if (_apiKey.isNotEmpty) {
        setState(() {});
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Settings()),
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
                MaterialPageRoute(builder: (context) => const Settings()),
              ).then((value) {
                loadConfiguration();
              });
            },
          ),
        ],
      ),
      body: SettingsDataWidget(
        apiKey: _apiKey,
        model: _model,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _responses.length,
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    return MessageView(
                      message: _responses.values
                          .elementAt(_responses.values.length - index - 1),
                    );
                  }),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MessageForm(callback: updateMessages),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

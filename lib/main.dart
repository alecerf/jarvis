import 'package:flutter/material.dart';
import 'package:jarvis/api_key_form_widget.dart';
import 'package:jarvis/api_key_widget.dart';
import 'package:jarvis/message_form_widget.dart';
import 'package:jarvis/message_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      _apiKey = prefs.getString('key') ?? "";
      if (_apiKey.isNotEmpty) {
        setState(() {});
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => ApiKeyForm(),
        ).then(
          (value) => setState(() {
            prefs.setString('key', value!).then((bool success) {
              if (success) {
                _apiKey = value;
              }
            });
          }),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Jarvis"),
      ),
      body: ApiKeyWidget(
        apiKey: _apiKey,
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

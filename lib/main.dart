import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jarvis/api_key_form_widget.dart';
import 'package:jarvis/api_key_widget.dart';
import 'package:jarvis/message_form_widget.dart';
import 'package:jarvis/message_widget.dart';

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
  String apiKey = "";
  Map<String, MessageData> responses = <String, MessageData>{};

  void updateMessages(String? userInput, String? response, String id) {
    setState(() {
      responses.update(
        id,
        (value) {
          responses[id]!.response = responses[id]!.response! + response!;
          return responses[id]!;
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
    if (apiKey.isNotEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ApiKeyForm(),
      ).then(
        (value) => setState(() => apiKey = value ?? ""),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Jarvis"),
      ),
      body: ApiKeyWidget(
        apiKey: apiKey,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: responses.length,
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    return MessageView(
                      message: responses.values
                          .elementAt(responses.values.length - index - 1),
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

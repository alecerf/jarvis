import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jarvis/api_key_form.dart';
import 'package:jarvis/message_form.dart';
import 'package:jarvis/message.dart';
import 'package:jarvis/mistral.dart';

void main() {
  runApp(const Jarvis());
}

class Jarvis extends StatelessWidget {
  const Jarvis({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J.A.R.V.I.S',
      debugShowCheckedModeBanner: false,
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
  Queue<MessageData> responses = Queue<MessageData>();
  String apiKey = "";

  void updateMessages(String data, bool fromClient) {
    setState(() {
      responses
          .addFirst(MessageData(mistralResponse: data, fromClient: fromClient));
    });
  }

  void setupApiKey(String data) {
    setState(() {
      apiKey = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("J.A.R.V.I.S"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.key),
              tooltip: 'Set App Key',
              onPressed: () => showDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => ApiKeyForm(setupApiKey)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: responses.length,
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    if (!responses.elementAt(index).fromClient) {
                      MistralResponse response = MistralResponse.fromJson(
                          jsonDecode(
                              responses.elementAt(index).mistralResponse));
                      return MessageView(
                          data: response.choices.first.message.content);
                    } else {
                      return MessageView(
                          data: responses.elementAt(index).mistralResponse);
                    }
                  }),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MessageForm(updateMessages, apiKey),
                )),
          ],
        ));
  }
}

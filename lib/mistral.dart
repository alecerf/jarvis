import 'dart:convert';

import 'package:http/http.dart' as http;

class Usage {
  final int promptTokens;
  final int totalTokens;
  final int completionTokens;

  Usage(this.promptTokens, this.totalTokens, this.completionTokens);

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      json['prompt_tokens'],
      json['total_tokens'],
      json['completion_tokens'],
    );
  }
}

class Message {
  final String role;
  final String content;

  Message(this.role, this.content);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      json['role'],
      json['content'],
    );
  }
}

class Choice {
  final int index;
  final Message message;
  final String finishReason;

  Choice(this.index, this.message, this.finishReason);

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      json['index'],
      Message.fromJson(json['message']),
      json['finish_reason'],
    );
  }
}

class MistralResponse {
  final String id;
  final String object;
  final int created;
  final String model;

  final List<Choice> choices;
  final Usage usage;

  MistralResponse(
      this.id, this.object, this.created, this.model, this.choices, this.usage);

  factory MistralResponse.fromJson(Map<String, dynamic> json) {
    return MistralResponse(
      json['id'],
      json['object'],
      json['created'],
      json['model'],
      (json['choices'] as List).map((i) => Choice.fromJson(i)).toList(),
      Usage.fromJson(json['usage']),
    );
  }
}

Future<http.Response> ask(String message, apiKey) {
  return http.post(
    Uri.parse('https://api.mistral.ai/v1/chat/completions'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode(<String, Object?>{
      "model": "mistral-tiny",
      "messages": [
        {"role": "user", "content": message}
      ],
    }),
  );
}

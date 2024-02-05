import 'dart:convert';

import 'package:fetch_client/fetch_client.dart';
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

class Delta {
  final String? role;
  final String content;

  Delta({this.role, required this.content});

  factory Delta.fromJson(Map<String, dynamic> json) {
    return Delta(
      role: json['role'] as String?,
      content: json['content'],
    );
  }
}

class Choice {
  final int index;
  final Delta delta;
  final String? finishReason;

  Choice({required this.index, required this.delta, this.finishReason});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'],
      delta: Delta.fromJson(json['delta']),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

class MistralResponse {
  final String id;
  final String object;
  final int created;
  final String model;

  final List<Choice> choices;
  final Usage? usage;

  MistralResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory MistralResponse.fromJson(Map<String, dynamic> json) {
    return MistralResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices:
          (json['choices'] as List).map((i) => Choice.fromJson(i)).toList(),
      usage: json['usage'] == Null ? Usage.fromJson(json['usage']) : null,
    );
  }
}

Future<http.StreamedResponse> ask(String message, apiKey) {
  var request = http.StreamedRequest(
      'POST', Uri.parse('https://api.mistral.ai/v1/chat/completions'))
    ..headers['Content-Type'] = 'application/json'
    ..headers['Authorization'] = 'Bearer $apiKey'
    ..sink.add(utf8.encode(jsonEncode(<String, Object?>{
      "stream": true,
      "model": "mistral-tiny",
      "messages": [
        {"role": "user", "content": message}
      ],
    })))
    ..sink.close();
  return FetchClient(mode: RequestMode.cors).send(request);
}

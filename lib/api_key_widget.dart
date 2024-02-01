import 'package:flutter/material.dart';

class ApiKeyWidget extends InheritedWidget {
  final String apiKey;

  const ApiKeyWidget({super.key, required this.apiKey, required super.child});

  @override
  bool updateShouldNotify(ApiKeyWidget oldWidget) {
    return apiKey != oldWidget.apiKey;
  }

  static ApiKeyWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiKeyWidget>()!;
  }
}

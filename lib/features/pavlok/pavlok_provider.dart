import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pavlok_provider.g.dart';

@riverpod
Future<void> pavlok(Ref ref) async {
  const pavlokUrl = 'https://api.pavlok.com/api/v5/stimulus/send';
  final apiKey = dotenv.env['PAVLOK_API_KEY'] ?? '';

  if (apiKey.isEmpty) {
    debugPrint('PAVLOK_API_KEY is not set. Skipping Pavlok stimulus.');
    return;
  }

  await http
      .post(
        Uri.parse(pavlokUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'stimulus': {'stimulusType': 'zap', 'stimulusValue': 25},
        }),
      )
      .timeout(const Duration(seconds: 5));
}

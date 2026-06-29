import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ai_config.dart';
import 'ai_models.dart';

/// Talks to the `ai` Supabase Edge Function (which proxies MiniMax). Every
/// method throws on any failure (network, timeout, bad status, malformed body)
/// so the [AiService] facade can catch it and fall back to on-device
/// generation. This client never decides policy — it just calls and parses.
///
/// The function is one endpoint with an `action` field; the anon key is sent as
/// both `apikey` and `Authorization: Bearer` per Supabase's gateway.
class LiveAiClient {
  LiveAiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> _call(String action, Map<String, dynamic> body) async {
    final uri = Uri.parse(AiConfig.functionUrl);
    final res = await _client
        .post(
          uri,
          headers: {
            'content-type': 'application/json',
            'apikey': AiConfig.supabaseAnonKey,
            'authorization': 'Bearer ${AiConfig.supabaseAnonKey}',
          },
          body: jsonEncode({'action': action, ...body}),
        )
        .timeout(AiConfig.timeout);

    if (res.statusCode != 200) {
      throw Exception('AI function ${res.statusCode}: ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('AI function returned non-object');
    }
    return decoded;
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> j) {
    final raw = j['items'];
    if (raw is! List) throw const FormatException('missing items');
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<AiArrival>> arrivals(int count) async {
    final j = await _call('gags', {'kind': 'arrival', 'count': count});
    return _items(j).map(AiArrival.fromJson).toList();
  }

  Future<List<AiReview>> reviews(int count) async {
    final j = await _call('gags', {'kind': 'review', 'count': count});
    return _items(j).map(AiReview.fromJson).toList();
  }

  Future<List<AiLatePrediction>> latePredictions(int count) async {
    final j = await _call('gags', {'kind': 'late', 'count': count});
    return _items(j).map(AiLatePrediction.fromJson).toList();
  }

  Future<List<AiPrank>> pranks(int count) async {
    final j = await _call('gags', {'kind': 'prank', 'count': count});
    return _items(j).map(AiPrank.fromJson).toList();
  }

  Future<List<String>> mapGags(int count) async {
    final j = await _call('gags', {'kind': 'map', 'count': count});
    return (j['items'] as List).whereType<String>().toList();
  }

  Future<List<String>> feed(int count) async {
    final j = await _call('gags', {'kind': 'feed', 'count': count});
    return (j['items'] as List).whereType<String>().toList();
  }

  Future<String> uncle(List<UncleTurn> history) async {
    // Drop any leading assistant turns (e.g. the uncle's opening greeting) so the
    // conversation sent to the model starts with a user message.
    final trimmed = [...history];
    while (trimmed.isNotEmpty && !trimmed.first.fromUser) {
      trimmed.removeAt(0);
    }
    final j = await _call('uncle', {'messages': trimmed.map((t) => t.toJson()).toList()});
    final text = (j['text'] ?? '') as String;
    if (text.trim().isEmpty) throw const FormatException('empty uncle reply');
    return text.trim();
  }

  Future<AiRoast> roast(String destination) async {
    final j = await _call('roast', {'destination': destination});
    return AiRoast.fromJson(j);
  }

  Future<AiCertificate> certificate({String? seed}) async {
    final j = await _call('certificate', {if (seed != null) 'seed': seed});
    return AiCertificate.fromJson(j);
  }

  void dispose() => _client.close();
}

/// Logs in debug only — never logs user text in release.
void aiDebug(Object? message) {
  if (kDebugMode) debugPrint('[ai] $message');
}

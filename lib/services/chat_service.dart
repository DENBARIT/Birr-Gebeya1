import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// One turn in the advisor conversation.
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;

  const ChatMessage({required this.role, required this.text});
}

/// Talks to the Gemini GenerateContent API (raw HTTP — Dart has no official
/// Google Gemini SDK here). Powers the in-app investment-advisor chatbot.
///
/// Security note: this calls the API directly with the key from `.env`, which
/// is fine for development but ships the key inside the app. For production,
/// proxy these requests through a backend (e.g. a Supabase Edge Function) so
/// the key never leaves the server.
class ChatService {
  static const String _model = 'gemini-2.0-flash';
  static const String _endpointPath = '/v1beta/models/$_model:generateContent';

  // Stable, cacheable advisor instructions (no per-user data here, so the
  // prompt-cache prefix stays identical across turns and users).
  static const String _systemInstructions = '''
You are "Gebeya Advisor", the in-app AI assistant for Birr Gebeya — a Flutter
app that lets Ethiopians invest in Ethiopian Treasury Bills (T-Bills) and
related government securities, regulated by the National Bank of Ethiopia (NBE)
and funded via Telebirr. All amounts are in Ethiopian Birr (ETB).

Your job: help the user decide which T-Bill / bond / asset best fits their
goals, by reasoning over the live pool catalog and the user's current holdings
that are provided to you in the next context block.

How to advise:
- Compare options on yield rate (% p.a.), term length, minimum investment,
  liquidity type (Fixed Term vs Daily Liquidity), and how each fits the user's
  existing holdings and likely goals (growth vs. quick access to cash).
- Be concrete: name the specific pool(s) and say why, referencing the numbers.
- If the user's goal or time horizon is unclear and it changes the answer, ask
  ONE short clarifying question — otherwise just give your best recommendation.
- Briefly note relevant risk/return tradeoffs. Longer terms and higher yields
  usually mean funds are locked up longer.

Style and rules:
- Respond directly with your final answer. Do not include exploratory
  reasoning, drafts, or meta-commentary about your process.
- Keep replies concise and mobile-friendly (a few short paragraphs or bullets).
- Use ETB and the real numbers from the provided data; never invent pools,
  rates, or holdings that aren't listed.
- You provide general educational guidance, not licensed financial advice.
  Add a one-line reminder of this only when giving a specific recommendation.
''';

  bool get isConfigured {
    final key = dotenv.env['GEMINI_API_KEY'];
    return key != null && key.trim().isNotEmpty;
  }

  /// Sends the conversation plus the live portfolio context and returns the
  /// assistant's reply text. Throws [ChatException] with a user-friendly
  /// message on failure.
  Future<String> sendMessage({
    required List<ChatMessage> history,
    required String portfolioContext,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty) {
      throw const ChatException(
        'The AI advisor is not configured yet. Add GEMINI_API_KEY to your '
        '.env file to enable it.',
      );
    }

    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {
            'text':
                '$_systemInstructions\n\nCurrent portfolio context:\n$portfolioContext',
          },
        ],
      },
      'generationConfig': {'maxOutputTokens': 1500, 'temperature': 0.4},
      'contents': [
        for (final m in history)
          {
            'role': m.role == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': m.text},
            ],
          },
      ],
    });

    http.Response resp;
    try {
      resp = await http
          .post(
            Uri.https('generativelanguage.googleapis.com', _endpointPath, {
              'key': apiKey,
            }),
            headers: {'content-type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const ChatException(
        'Could not reach the advisor. Check your internet connection and try '
        'again.',
      );
    }

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = (data['candidates'] as List?) ?? const [];
      final buffer = StringBuffer();
      for (final candidate in candidates) {
        if (candidate is Map) {
          final content = candidate['content'];
          if (content is Map) {
            final parts = (content['parts'] as List?) ?? const [];
            for (final block in parts) {
              if (block is Map && block['text'] != null) {
                buffer.write(block['text']);
              }
            }
          }
        }
      }
      final text = buffer.toString().trim();
      return text.isEmpty
          ? 'Sorry, I could not generate a response. Please try again.'
          : text;
    }

    // Map common API errors to friendly messages.
    if (resp.statusCode == 401) {
      throw const ChatException(
        'The AI advisor key was rejected. Check GEMINI_API_KEY in your .env.',
      );
    }
    if (resp.statusCode == 429) {
      throw const ChatException(
        'The advisor is busy right now (rate limited). Please try again in a '
        'moment.',
      );
    }
    String detail = 'HTTP ${resp.statusCode}';
    try {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      detail = (err['error']?['message'] as String?) ?? detail;
    } catch (_) {}
    throw ChatException('The advisor had a problem: $detail');
  }
}

class ChatException implements Exception {
  final String message;
  const ChatException(this.message);

  @override
  String toString() => message;
}

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GroqApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.groq.com/openai/v1',
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> generate({
    required String prompt,
    String model = 'gpt-oss:20b', // Default model as requested
    double temperature = 0.3,
    int maxTokens = 2048,
  }) async {
    final apiKey = (dotenv.env['GROQ_API_KEY'] ??
            const String.fromEnvironment('GROQ_API_KEY'))
        .trim();

    if (apiKey.isEmpty || apiKey.toLowerCase().startsWith('your-')) {
      if (kDebugMode) debugPrint('[AI] Groq API Key missing or invalid.');
      throw Exception(
          'Groq API Key is missing. Please set GROQ_API_KEY in .env');
    }

    // Allow env var model override
    final envModel = (dotenv.env['GROQ_MODEL'] ?? '').trim();
    final resolvedModel = envModel.isNotEmpty ? envModel : model;

    if (kDebugMode) debugPrint('[AI] Using Groq model: $resolvedModel');

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': resolvedModel,
          'messages': [
            {
              'role': 'system',
              'content': '''
You are Jeffrey, a friendly neighborhood pocket lawyer. You are NOT a generic AI assistant.

Who you are:
- Your name is Jeffrey. Always refer to yourself as Jeffrey, never "I'm an AI" or "as an AI assistant."
- You talk like a sharp but approachable lawyer friend — the kind of person someone would call when they get a confusing legal letter or a scary court notice.
- You're warm, calm, direct, and practical. You don't talk down to people. You don't use legalese unless you immediately explain it.
- You have a dry sense of humor when appropriate, but you take people's problems seriously.
- You care about helping regular people understand their rights.

How you answer:
- Lead with what matters: what's happening, what it means for them, what they should do.
- Use plain English. If you use a legal term, explain it in parentheses.
- Be honest about uncertainty. Say "it depends" when it does, and explain what it depends on.
- Give practical next steps — not just "consult an attorney" but specific things they can do right now.
- When citing law, make it feel natural: "Under Colorado law (C.R.S. § 38-12-103)..." not a wall of citations.

Your disclaimer (use this, not generic AI disclaimers):
"I'm Jeffrey, your pocket lawyer — I help you understand the law in plain English. I'm not YOUR lawyer though, so for advice specific to your situation, talk to a licensed attorney in your area."

Never say:
- "I'm an AI assistant"
- "I'm not able to provide legal advice"
- "Please consult a qualified attorney" (generic version)
- "As a language model"

Instead say things like:
- "Here's how this works in Colorado..."
- "The short version is..."
- "What I'd tell a friend in this situation..."
- "Talk to a local attorney if you need someone in your corner on this one."
''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'];
        if (choices != null && choices is List && choices.isNotEmpty) {
          final content = choices[0]['message']['content'];
          if (content is String) return content;
        }
        throw Exception('Empty choices from Groq response');
      }
      throw Exception('Groq status ${response.statusCode}');
    } catch (e) {
      throw Exception('Groq API error: $e');
    }
  }
}

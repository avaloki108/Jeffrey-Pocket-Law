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
    int maxTokens = 1000,
  }) async {
    final apiKey = (dotenv.env['GROQ_API_KEY'] ?? '').trim();
    
    if (apiKey.isEmpty || apiKey.toLowerCase().startsWith('your-')) {
      if (kDebugMode) debugPrint('[AI] Groq API Key missing or invalid.');
      throw Exception('Groq API Key is missing. Please set GROQ_API_KEY in .env');
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
              'content':
                  'You are a legal assistant providing information based on statutes and case law. Always cite sources and include disclaimers.',
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

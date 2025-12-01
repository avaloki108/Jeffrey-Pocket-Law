import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAiApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<String> generate({
    required String prompt,
    String model = 'openai/gpt-oss-120b',
    double temperature = 0.3,
    int maxTokens = 1000,
  }) async {
    try {
      final apiKey = dotenv.env['OPENROUTER_API_KEY'] ??
          const String.fromEnvironment('OPENROUTER_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('OPENROUTER_API_KEY not found in .env file');
      }

      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://pocketlawyer.com',
            'X-Title': 'Pocket Lawyer',
          },
        ),
        data: {
          'model': model,
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
          if (content is String) {
            return content;
          }
        }
      }
      throw Exception(
          'Failed to get response from OpenRouter: ${response.statusCode}');
    } catch (e) {
      throw Exception('OpenRouter API error: $e');
    }
  }
}

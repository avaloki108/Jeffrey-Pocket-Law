import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class OpenRouterApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1',
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> generate({
    required String prompt,
    String model = 'openai/gpt-oss-120b',
    double temperature = 0.3,
    int maxTokens = 1000,
  }) async {
    final keyRaw = (dotenv.env['OPENROUTER_API_KEY'] ??
            const String.fromEnvironment('OPENROUTER_API_KEY'))
        .trim();
    final openRouterKey =
        (keyRaw.isEmpty || keyRaw.toLowerCase().startsWith('your-'))
            ? ''
            : keyRaw;

    // Allow env var model override for OpenRouter if provided
    final envRouterModel = (dotenv.env['OPENROUTER_MODEL'] ?? '').trim();
    final resolvedRouterModel =
        envRouterModel.isNotEmpty ? envRouterModel : model;

    if (openRouterKey.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[AI] Using OpenRouter model: $resolvedRouterModel');
      }
      return _generateViaOpenRouter(
        apiKey: openRouterKey,
        prompt: prompt,
        model: resolvedRouterModel,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    }
    // Fallback to local Ollama
    final ollamaModel = (dotenv.env['OLLAMA_MODEL'] ?? 'gpt-oss:latest').trim();
    if (kDebugMode) debugPrint('[AI] Using Ollama model: $ollamaModel');
    return _generateViaOllama(
      prompt: prompt,
      model: ollamaModel,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  Future<String> _generateViaOpenRouter({
    required String apiKey,
    required String prompt,
    required String model,
    required double temperature,
    required int maxTokens,
  }) async {
    try {
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
          if (content is String) return content;
        }
        throw Exception('Empty choices from OpenRouter response');
      }
      throw Exception('OpenRouter status ${response.statusCode}');
    } catch (e) {
      throw Exception('OpenRouter API error: $e');
    }
  }

  Future<String> _generateViaOllama({
    required String prompt,
    required String model,
    required double temperature,
    required int maxTokens,
  }) async {
    final ollamaHost = dotenv.env['OLLAMA_HOST'] ?? 'http://127.0.0.1:11434';
    final dio = Dio(
      BaseOptions(
        baseUrl: ollamaHost,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      // Non-streaming generate endpoint
      final response = await dio.post(
        '/api/generate',
        data: {
          'model': model,
          'prompt': prompt,
          'stream': false,
          // Ollama doesn't use temperature/max_tokens exactly the same way but we pass as options if supported later
          'options': {
            'temperature': temperature,
            'num_predict': maxTokens,
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['response'] is String) {
          return data['response'] as String;
        }
        throw Exception('Unexpected Ollama response shape');
      }
      throw Exception('Ollama status ${response.statusCode}');
    } catch (e) {
      throw Exception('Ollama local fallback error: $e');
    }
  }
}

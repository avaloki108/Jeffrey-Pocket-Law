import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/deepseek_api_client.dart';

final deepseekApiClientProvider = Provider<DeepSeekApiClient>((ref) {
  final key = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  final baseUrl = dotenv.env['DEEPSEEK_BASE_URL'] ?? 'https://api.deepseek.com/v1';
  final model = dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-chat';
  if (key.isEmpty) {
    if (kDebugMode) debugPrint('Warning: DEEPSEEK_API_KEY is not set. DeepSeek calls will fail.');
  }
  return DeepSeekApiClient(apiKey: key, baseUrl: baseUrl, defaultModel: model);
});

final deepseekChatRepositoryProvider = Provider<DeepSeekChatRepository>((ref) {
  final client = ref.watch(deepseekApiClientProvider);
  return DeepSeekChatRepository(client);
});

class DeepSeekChatRepository {
  final DeepSeekApiClient client;
  DeepSeekChatRepository(this.client);

  Future<String> ask(String userMessage, {String systemPrompt = 'You are a helpful legal information assistant. Provide general information, not legal advice.'}) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];
    return client.chat(messages: messages);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client_repository.dart';
import '../data/rag_repository.dart';
import '../data/secure_storage_repository.dart';
import '../domain/chat_usecase.dart';
import '../domain/prompts_usecase.dart';
import '../domain/settings_usecase.dart';
import '../infrastructure/congress_api_client.dart';
import '../infrastructure/legiscan_api_client.dart';
import '../infrastructure/open_router_api_client.dart';
import '../infrastructure/groq_api_client.dart';
import '../services/viral_growth_service.dart';
import 'deepseek_providers.dart';
import '../dataconnect_generated/generated.dart';
// import 'package:firebase_data_connect/firebase_data_connect.dart'; // Unused directly here, but used in generated.dart

// Export prompt selected provider for cross-screen communication
export '../domain/models/prompt_selected_notifier.dart'
    show promptSelectedProvider;

/// Tracks the number of successful chats.
final chatCounterProvider = StateProvider<int>((ref) => 0);

final openRouterClientProvider = Provider<OpenRouterApiClient>(
  (ref) => OpenRouterApiClient(),
);
final groqClientProvider = Provider<GroqApiClient>(
  (ref) => GroqApiClient(),
);
final legiScanClientProvider = Provider<LegiScanApiClient>(
  (ref) => LegiScanApiClient(),
);
final congressClientProvider = Provider<CongressApiClient>(
  (ref) => CongressApiClient(),
);

final apiClientRepositoryProvider = Provider<ApiClientRepository>((ref) {
  final openRouterClient = ref.read(openRouterClientProvider);
  final deepSeekClient =
      ref.read(deepseekApiClientProvider); // From deepseek_providers.dart
  final groqClient = ref.read(groqClientProvider);
  final legiScanClient = ref.read(legiScanClientProvider);
  final congressClient = ref.read(congressClientProvider);
  return ApiClientRepository(openRouterClient, deepSeekClient, groqClient,
      legiScanClient, congressClient);
});

final ragRepositoryProvider = Provider<RagRepository>((ref) {
  final apiClient = ref.read(apiClientRepositoryProvider);
  return RagRepositoryImpl(apiClient);
});

final secureStorageProvider = Provider<SecureStorageRepository>(
  (ref) => SecureStorageRepository(),
);

// Viral growth service for referrals, reviews, sharing
final viralGrowthServiceProvider = Provider<ViralGrowthService>((ref) {
  return ViralGrowthService();
});

final dataConnectProvider = Provider<ExampleConnector>((ref) {
  return ExampleConnector.instance;
});

final chatUseCaseProvider = Provider<ChatUseCase>((ref) {
  final repo = ref.read(ragRepositoryProvider);
  final connector = ref.read(dataConnectProvider);
  return ChatUseCase(repo, connector);
});

final promptsUseCaseProvider = Provider<PromptsUseCase>(
  (ref) => PromptsUseCase(),
);

final settingsUseCaseProvider = Provider<SettingsUseCase>((ref) {
  final storage = ref.read(secureStorageProvider);
  return SettingsUseCase(storage);
});

final selectedStateProvider = StateProvider<String>((ref) => 'CO');

const stateNameToAbbr = {
  'California': 'CA',
  'Colorado': 'CO',
  'New Mexico': 'NM',
  'New York': 'NY',
  'Texas': 'TX',
};

const abbrToStateName = {
  'CA': 'California',
  'CO': 'Colorado',
  'NM': 'New Mexico',
  'NY': 'New York',
  'TX': 'Texas',
};

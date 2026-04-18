import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/api_client_repository.dart';
import '../data/auth_repository.dart';
import '../data/rag_repository.dart';
import '../data/secure_storage_repository.dart';
import '../dataconnect_generated/generated.dart';
import '../domain/chat_usecase.dart';
import '../domain/prompts_usecase.dart';
import '../domain/settings_usecase.dart';
import '../infrastructure/congress_api_client.dart';
import '../infrastructure/groq_api_client.dart';
import '../infrastructure/legiscan_api_client.dart';
import '../infrastructure/open_router_api_client.dart';
import '../services/complete_legal_ai_service.dart';
import '../services/viral_growth_service.dart';
import '../core/revenuecat_service.dart';
import 'deepseek_providers.dart';

// import 'package:firebase_data_connect/firebase_data_connect.dart'; // Unused directly here, but used in generated.dart

// Export prompt selected provider for cross-screen communication
export '../domain/models/prompt_selected_notifier.dart'
    show promptSelectedProvider;

/// Tracks the number of successful chats.
final chatCounterProvider = StateProvider<int>((ref) => 0);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

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

final completeLegalAIServiceProvider = Provider<CompleteLegalAIService>((ref) {
  final groqClient = ref.read(groqClientProvider);
  return CompleteLegalAIService(groqApiClient: groqClient);
});

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
  final legalService = ref.read(completeLegalAIServiceProvider);
  return RagRepositoryImpl(legalService);
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
final selectedJurisdictionProvider = StateProvider<String>((ref) => 'State');
final selectedCountyProvider = StateProvider<String>((ref) => '');
final selectedPlanProvider = StateProvider<String>((ref) => 'Free');

// Personalization providers
final userNameProvider = StateProvider<String>((ref) => '');
final lawyerNameProvider = StateProvider<String>((ref) => 'Jeffrey');
final userAgeRangeProvider = StateProvider<String>((ref) => '25-34');
final userUseCasesProvider = StateProvider<List<String>>((ref) => []);

// Response style preference
enum ResponseStyle {
  standard,
  quickCasual,
  detailed,
  justFacts,
  explainLikeFive,
}

final responseStyleProvider = StateProvider<ResponseStyle>((ref) => ResponseStyle.standard);

// Agent state for UI feedback
enum AgentState {
  idle,
  researching,
  analyzing,
  answering,
}

final agentStateProvider = StateProvider<AgentState>((ref) => AgentState.idle);

const stateNameToAbbr = {
  'Alabama': 'AL',
  'Alaska': 'AK',
  'Arizona': 'AZ',
  'Arkansas': 'AR',
  'California': 'CA',
  'Colorado': 'CO',
  'Connecticut': 'CT',
  'Delaware': 'DE',
  'Florida': 'FL',
  'Georgia': 'GA',
  'Hawaii': 'HI',
  'Idaho': 'ID',
  'Illinois': 'IL',
  'Indiana': 'IN',
  'Iowa': 'IA',
  'Kansas': 'KS',
  'Kentucky': 'KY',
  'Louisiana': 'LA',
  'Maine': 'ME',
  'Maryland': 'MD',
  'Massachusetts': 'MA',
  'Michigan': 'MI',
  'Minnesota': 'MN',
  'Mississippi': 'MS',
  'Missouri': 'MO',
  'Montana': 'MT',
  'Nebraska': 'NE',
  'Nevada': 'NV',
  'New Hampshire': 'NH',
  'New Jersey': 'NJ',
  'New Mexico': 'NM',
  'New York': 'NY',
  'North Carolina': 'NC',
  'North Dakota': 'ND',
  'Ohio': 'OH',
  'Oklahoma': 'OK',
  'Oregon': 'OR',
  'Pennsylvania': 'PA',
  'Rhode Island': 'RI',
  'South Carolina': 'SC',
  'South Dakota': 'SD',
  'Tennessee': 'TN',
  'Texas': 'TX',
  'Utah': 'UT',
  'Vermont': 'VT',
  'Virginia': 'VA',
  'Washington': 'WA',
  'West Virginia': 'WV',
  'Wisconsin': 'WI',
  'Wyoming': 'WY',
};

const abbrToStateName = {
  'AL': 'Alabama',
  'AK': 'Alaska',
  'AZ': 'Arizona',
  'AR': 'Arkansas',
  'CA': 'California',
  'CO': 'Colorado',
  'CT': 'Connecticut',
  'DE': 'Delaware',
  'FL': 'Florida',
  'GA': 'Georgia',
  'HI': 'Hawaii',
  'ID': 'Idaho',
  'IL': 'Illinois',
  'IN': 'Indiana',
  'IA': 'Iowa',
  'KS': 'Kansas',
  'KY': 'Kentucky',
  'LA': 'Louisiana',
  'ME': 'Maine',
  'MD': 'Maryland',
  'MA': 'Massachusetts',
  'MI': 'Michigan',
  'MN': 'Minnesota',
  'MS': 'Mississippi',
  'MO': 'Missouri',
  'MT': 'Montana',
  'NE': 'Nebraska',
  'NV': 'Nevada',
  'NH': 'New Hampshire',
  'NJ': 'New Jersey',
  'NM': 'New Mexico',
  'NY': 'New York',
  'NC': 'North Carolina',
  'ND': 'North Dakota',
  'OH': 'Ohio',
  'OK': 'Oklahoma',
  'OR': 'Oregon',
  'PA': 'Pennsylvania',
  'RI': 'Rhode Island',
  'SC': 'South Carolina',
  'SD': 'South Dakota',
  'TN': 'Tennessee',
  'TX': 'Texas',
  'UT': 'Utah',
  'VT': 'Vermont',
  'VA': 'Virginia',
  'WA': 'Washington',
  'WV': 'West Virginia',
  'WI': 'Wisconsin',
  'WY': 'Wyoming',
};

// RevenueCat providers
final hasProAccessProvider = FutureProvider<bool>((ref) async {
  return await RevenueCatService.hasProAccess();
});

final subscriptionStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await RevenueCatService.getSubscriptionStatus();
});

final currentOfferingProvider = FutureProvider((ref) async {
  return await RevenueCatService.getCurrentOffering();
});

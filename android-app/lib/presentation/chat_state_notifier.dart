import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/legal_source.dart';
import '../domain/chat_usecase.dart';
import '../services/viral_growth_service.dart';
import 'providers.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? sessionId;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.sessionId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? sessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatUseCase _chatUseCase;
  final ViralGrowthService _viralService;
  final Ref _ref;

  ChatNotifier(this._chatUseCase, this._viralService, this._ref) : super(ChatState()) {
    // Initialize session ID if not already set
    if (state.sessionId == null) {
      state = state.copyWith(
          sessionId: DateTime.now().millisecondsSinceEpoch.toString());
    }
  }

  void _setAgentState(AgentState agentState) {
    _ref.read(agentStateProvider.notifier).state = agentState;
  }

  Future<void> sendMessage(
    String text,
    String stateAbbr, {
    String jurisdiction = 'State',
    String county = '',
    String plan = 'Free',
    String userName = '',
    String lawyerName = 'Jeffrey',
    String ageRange = '25-34',
    List<String> useCases = const [],
    ResponseStyle? responseStyle,
  }) async {
    if (text.trim().isEmpty || state.isLoading) return;

    // Add user message
    final userMsg =
        ChatMessage(content: text, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      // Set agent states for UX feedback
      _setAgentState(AgentState.researching);
      await Future.delayed(const Duration(milliseconds: 500));

      _setAgentState(AgentState.analyzing);
      await Future.delayed(const Duration(milliseconds: 500));

      _setAgentState(AgentState.answering);

      // Build conversation context (last 10 messages for context window efficiency)
      final conversationHistory = state.messages
          .take(10)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.content,
              })
          .toList();

      // Get response style from provider if not explicitly passed
      final style =
          responseStyle ?? _ref.read(responseStyleProvider.notifier).state;

      final response = await _chatUseCase.sendMessage(
        text,
        stateAbbr,
        sessionId: state.sessionId,
        jurisdiction: jurisdiction,
        county: county,
        plan: plan,
        userName: userName,
        lawyerName: lawyerName,
        ageRange: ageRange,
        useCases: useCases,
        conversationHistory: conversationHistory,
        responseStyle: style,
      );

      final botMsg = ChatMessage(
        content: response['content'] as String,
        isUser: false,
        timestamp: DateTime.now(),
        sources: (response['sources'] as List?)
            ?.map((s) => LegalSource.fromJson(s as Map<String, dynamic>))
            .toList(),
        confidence: response['confidence'] as double?,
        followUpSuggestions: (response['followUpSuggestions'] as List?)
            ?.map((s) => s as String)
            .toList(),
      );

      _setAgentState(AgentState.idle);

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );

      _viralService.requestReview();
    } catch (e) {
      _setAgentState(AgentState.idle);
      final errorMsg = ChatMessage(
        content: 'Error: ${e.toString()}\n\nCheck API credentials or rephrase.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = state.copyWith(
        messages: [],
        sessionId: DateTime.now().millisecondsSinceEpoch.toString());
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatUseCase = ref.read(chatUseCaseProvider);
  final viralService = ref.read(viralGrowthServiceProvider);
  return ChatNotifier(chatUseCase, viralService, ref);
});

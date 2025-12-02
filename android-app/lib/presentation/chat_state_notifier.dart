import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  ChatNotifier(this._chatUseCase, this._viralService) : super(ChatState()) {
    // Initialize session ID if not already set
    if (state.sessionId == null) {
      state = state.copyWith(
          sessionId: DateTime.now().millisecondsSinceEpoch.toString());
    }
  }

  Future<void> sendMessage(String text, String stateAbbr) async {
    if (text.trim().isEmpty || state.isLoading) return;

    // Add user message
    final userMsg =
        ChatMessage(content: text, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final response = await _chatUseCase.sendMessage(text, stateAbbr,
          sessionId: state.sessionId);

      final botMsg = ChatMessage(
        content: response['content'] as String,
        isUser: false,
        timestamp: DateTime.now(),
        sources: (response['sources'] as List?)
            ?.map((s) => LegalSource.fromJson(s as Map<String, dynamic>))
            .toList(),
        confidence: response['confidence'] as double?,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );

      _viralService.requestReview();
    } catch (e) {
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
  return ChatNotifier(chatUseCase, viralService);
});

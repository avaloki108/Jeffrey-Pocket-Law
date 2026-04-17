import '../data/rag_repository.dart';
import '../dataconnect_generated/generated.dart';

class ChatUseCase {
  final RagRepository _ragRepository;
  final ExampleConnector _connector;

  ChatUseCase(this._ragRepository, this._connector);

  Future<Map<String, dynamic>> sendMessage(
    String query,
    String state, {
    String? sessionId,
    String jurisdiction = 'State',
    String county = '',
    String plan = 'Free',
  }) async {
    final response = await _ragRepository.performRAGQuery(
      query,
      state,
      jurisdiction: jurisdiction,
      county: county,
      plan: plan,
    );

    // 2. Persist if sessionId is provided
    if (sessionId != null) {
      try {
        await _connector
            .sendMessage(sessionId: sessionId, content: query, sender: 'user')
            .execute();

        await _connector
            .sendMessage(
                sessionId: sessionId,
                content: response['content'] as String,
                sender: 'ai')
            .execute();
      } catch (e) {
        // Fail silently on persistence error to not block UI
        print('Failed to persist message: $e');
      }
    }

    return response;
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String sessionId) async {
    try {
      final result =
          await _connector.getChatHistory(sessionId: sessionId).execute();
      final messages = result.data.chatSession?.messages ?? [];

      return messages
          .map((m) => {
                'content': m.content,
                'isUser': m.sender == 'user',
                'timestamp': DateTime
                    .now(), // TODO: Convert m.timestamp to DateTime correctly
              })
          .toList();
    } catch (e) {
      print('Failed to fetch chat history: $e');
      return [];
    }
  }
}

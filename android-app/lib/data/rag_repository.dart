import 'api_client_repository.dart';
import '../services/complete_legal_ai_service.dart';

abstract class RagRepository {
  Future<String> query(String prompt);
  Future<Map<String, dynamic>> performRAGQuery(String prompt, String state);
}

// Real implementation using external APIs and Firebase AI
class RagRepositoryImpl implements RagRepository {
  final ApiClientRepository _apiClient;
  final CompleteLegalAIService _legalService;

  RagRepositoryImpl(this._apiClient, this._legalService);

  @override
  Future<String> query(String prompt) async {
    final result = await performRAGQuery(prompt, '');
    return result['content'] as String;
  }

  @override
  Future<Map<String, dynamic>> performRAGQuery(String prompt, String state) async {
    try {
      // Use the comprehensive query from CompleteLegalAIService which uses Firebase AI + Law APIs
      final result = await _legalService.comprehensiveLegalQuery(
        userQuery: prompt,
        jurisdiction: state.isNotEmpty ? state : null,
        searchCaseLaw: true,
        searchStatutes: true,
        searchCongress: true,
      );

      return {
        'content': result['ai_analysis'],
        'sources': (result['citations'] as List?)?.map((c) => {
          'citation': c,
          'url': '', // URL logic could be enhanced if returned from service
          'type': 'legal_source',
        }).toList() ?? [],
        'confidence': 0.85,
      };
    } catch (e) {
      // Ultimate fallback
      return {
        'content': 'I apologize, but I encountered an error while researching your legal question. Please consult with a qualified attorney for personalized legal advice. Error: $e',
        'sources': [],
        'confidence': 0.0,
      };
    }
  }
}
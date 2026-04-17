import '../services/complete_legal_ai_service.dart';

abstract class RagRepository {
  Future<String> query(String prompt);
  Future<Map<String, dynamic>> performRAGQuery(
    String prompt,
    String state, {
    String jurisdiction = 'State',
    String county = '',
    String plan = 'Free',
  });
}

// Real implementation using external APIs and Firebase AI
class RagRepositoryImpl implements RagRepository {
  final CompleteLegalAIService _legalService;

  RagRepositoryImpl(this._legalService);

  @override
  Future<String> query(String prompt) async {
    final result = await performRAGQuery(prompt, '');
    return result['content'] as String;
  }

  @override
  Future<Map<String, dynamic>> performRAGQuery(
    String prompt,
    String state, {
    String jurisdiction = 'State',
    String county = '',
    String plan = 'Free',
  }) async {
    try {
      final scope = jurisdiction == 'County' && county.trim().isNotEmpty
          ? '$county County, $state'
          : jurisdiction == 'Federal'
              ? 'Federal law in the United States'
              : '$state state law';
      final rewrittenPrompt = '''
Explain this legal issue in plain everyday language for a regular person.

User plan: $plan
Jurisdiction scope: $scope

Requirements:
- Lead with a short direct answer
- Then explain what it means in plain English
- Call out whether this is county, state, or federal specific
- Mention practical next steps
- Include source-based citations when available
- Do not pretend this is legal advice

User question: $prompt
''';

      final result = await _legalService.comprehensiveLegalQuery(
        userQuery: rewrittenPrompt,
        jurisdiction: state.isNotEmpty ? state : null,
        searchCaseLaw: true,
        searchStatutes: true,
        searchCongress: true,
      );

      return {
        'content': result['ai_analysis'],
        'sources': (result['citations'] as List?)
                ?.map((c) => {
                      'citation': c,
                      'url':
                          '', // URL logic could be enhanced if returned from service
                      'type': 'legal_source',
                    })
                .toList() ??
            [],
        'confidence': 0.85,
      };
    } catch (e) {
      // Ultimate fallback
      return {
        'content':
            'I apologize, but I encountered an error while researching your legal question. Please consult with a qualified attorney for personalized legal advice. Error: $e',
        'sources': [],
        'confidence': 0.0,
      };
    }
  }
}

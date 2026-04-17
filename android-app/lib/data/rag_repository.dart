import '../services/complete_legal_ai_service.dart';

abstract class RagRepository {
  Future<String> query(String prompt);
  Future<Map<String, dynamic>> performRAGQuery(
    String prompt,
    String state, {
    String jurisdiction = 'State',
    String county = '',
    String plan = 'Free',
    String userName = '',
    String lawyerName = 'Jeffrey',
    String ageRange = '25-34',
    List<String> useCases = const [],
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
    String userName = '',
    String lawyerName = 'Jeffrey',
    String ageRange = '25-34',
    List<String> useCases = const [],
  }) async {
    try {
      final scope = jurisdiction == 'County' && county.trim().isNotEmpty
          ? '$county County, $state'
          : jurisdiction == 'Federal'
              ? 'Federal law in the United States'
              : '$state state law';

      final userContext = userName.isNotEmpty
          ? 'The user\'s name is $userName. They are in the $ageRange age range.'
          : '';
      final focusAreas = useCases.isNotEmpty
          ? 'Their main legal interests are: ${useCases.join(", ")}.'
          : '';
      final name = lawyerName.isNotEmpty ? lawyerName : 'Jeffrey';

      // Build the LLM prompt (structured sections)
      final rewrittenPrompt = '''
You are $name, a friendly neighborhood pocket lawyer. Answer this question for a regular person.
$userContext
$focusAreas

User plan: $plan
Jurisdiction scope: $scope

Format the response in markdown with these exact sections:
## Short answer
## What this means
## What to do next
## Scope

Requirements:
- Keep the short answer to 2 to 4 sentences
- Use plain English, explain any legal terms in parentheses
- Be practical and calm, like a sharp lawyer friend
- Clearly say whether the answer is county, state, or federal specific
- If the law is uncertain or fact dependent, say that honestly
- Cite specific statutes or case law naturally when available
- End with your signature disclaimer: "I'm $name, your pocket lawyer — I help you understand the law in plain English. I'm not YOUR lawyer though, so for advice specific to your situation, talk to a licensed attorney in your area."

User question: $prompt
''';

      final result = await _legalService.comprehensiveLegalQuery(
        userQuery: prompt,
        llmPrompt: rewrittenPrompt,
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
                      'url': '',
                      'type': 'legal_source',
                    })
                .toList() ??
            [],
        'confidence':
            (result['ai_analysis'] as String).contains('Unable to generate')
                ? 0.0
                : 0.85,
      };
    } catch (e) {
      // Ultimate fallback
      return {
        'content':
            'Jeffrey couldn\'t connect to the legal research services right now. This usually means the AI backend (Groq or Gemini) is temporarily unavailable. Try again in a moment.\n\nError: $e',
        'sources': [],
        'confidence': 0.0,
      };
    }
  }
}

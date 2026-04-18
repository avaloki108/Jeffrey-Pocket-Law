import '../services/complete_legal_ai_service.dart';
import '../presentation/providers.dart' show ResponseStyle;

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
    List<Map<String, String>>? conversationHistory,
    ResponseStyle responseStyle = ResponseStyle.standard,
  });
  Future<String> generateConversationSummary(
    List<String> userQuestions,
    List<String> aiResponses,
  );
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
    List<Map<String, String>>? conversationHistory,
    ResponseStyle responseStyle = ResponseStyle.standard,
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

      // Build conversation context from history
      String conversationContext = '';
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.take(6).toList(); // Last 6 messages for context
        if (recentHistory.length > 1) { // More than just current message
          conversationContext = '\n\nCONVERSATION HISTORY (for context):\n';
          for (final msg in recentHistory) {
            final role = msg['role'] == 'user' ? 'User' : 'You ($name)';
            conversationContext += '$role: ${msg['content']}\n\n';
          }
          conversationContext += 'END CONVERSATION HISTORY\n\n';
        }
      }

      // Response style instructions
      final styleInstructions = _getStyleInstructions(responseStyle, name);

      // Build the LLM prompt (structured sections)
      final rewrittenPrompt = '''
You are $name, a friendly neighborhood pocket lawyer. Answer this question for a regular person.
$userContext
$focusAreas
$conversationContext
User plan: $plan
Jurisdiction scope: $scope

RESPONSE STYLE: ${_getStyleLabel(responseStyle)}

$styleInstructions

IMPORTANT INSTRUCTIONS:
- This is a CONVERSATION, so reference previous context above when relevant
- If the user asks a follow-up question, build upon your previous answers
- Keep track of what we've already discussed
- Acknowledge if you're expanding on or clarifying a previous point

Format the response in markdown with these exact sections:
${_getResponseSections(responseStyle)}

Requirements:
${_getResponseRequirements(responseStyle, name)}

After all sections, add this exact section:
## Suggested follow-up questions
Generate 3 relevant follow-up questions the user might have. Format each as a separate bullet point starting with "- ". Make them specific and actionable.

Current user question: $prompt
''';

      final result = await _legalService.comprehensiveLegalQuery(
        userQuery: prompt,
        llmPrompt: rewrittenPrompt,
        jurisdiction: state.isNotEmpty ? state : null,
        searchCaseLaw: true,
        searchStatutes: true,
        searchCongress: true,
      );

      // Calculate dynamic confidence based on response quality
      final analysis = result['ai_analysis'] as String;
      final citations = result['citations'] as List?;
      final hasCitations = citations != null && citations.isNotEmpty;
      final responseLength = analysis.length;

      // Base confidence
      double confidence = 0.5;

      // Boost for having sources
      if (hasCitations) {
        confidence += 0.25;
      }

      // Boost for substantive response (at least 200 chars)
      if (responseLength > 200) {
        confidence += 0.1;
      }

      // Boost for longer, detailed responses (at least 500 chars)
      if (responseLength > 500) {
        confidence += 0.1;
      }

      // Penalize for uncertainty indicators
      final uncertaintyIndicators = [
        'uncertain',
        'depends on',
        'may vary',
        'fact-dependent',
        'consult an attorney',
        'not legal advice',
        'unable to determine',
      ];
      final lowerAnalysis = analysis.toLowerCase();
      for (final indicator in uncertaintyIndicators) {
        if (lowerAnalysis.contains(indicator)) {
          confidence -= 0.05;
        }
      }

      // Boost for structured response with required sections
      final requiredSections = ['## Short answer', '## What this means', '## What to do next'];
      for (final section in requiredSections) {
        if (analysis.contains(section)) {
          confidence += 0.03;
        }
      }

      // Extract follow-up suggestions from response
      final followUpSuggestions = _extractFollowUpSuggestions(analysis);

      // Clamp between 0.0 and 1.0
      confidence = confidence.clamp(0.0, 1.0);

      return {
        'content': analysis,
        'sources': citations
                ?.map((c) => {
                      'citation': c,
                      'url': '',
                      'type': 'legal_source',
                    })
                .toList() ??
            [],
        'confidence': confidence,
        'followUpSuggestions': followUpSuggestions,
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

  String _getStyleInstructions(ResponseStyle style, String name) {
    switch (style) {
      case ResponseStyle.quickCasual:
        return '''
- Keep it BRIEF and conversational
- Use casual language like you're texting a friend
- Skip the deep legal analysis
- Get straight to the point
- Use phrases like "basically" and "long story short"
''';
      case ResponseStyle.detailed:
        return '''
- Provide a THOROUGH, comprehensive answer
- Cover all relevant angles and considerations
- Include background context when helpful
- Go deep on the "why" behind the law
- Anticipate follow-up questions
''';
      case ResponseStyle.justFacts:
        return '''
- Present information objectively and neutrally
- Remove personal commentary and conversational filler
- Focus on the law itself, not your opinion
- Use formal, straightforward language
- Omit humor and casual expressions
''';
      case ResponseStyle.explainLikeFive:
        return '''
- Explain like you're talking to a 5-year-old
- Use simple analogies and everyday comparisons
- Break down complex ideas into tiny pieces
- Avoid jargon entirely, or explain it with a metaphor
- Be warm and patient
''';
      case ResponseStyle.standard:
      default:
        return '''
- Keep the short answer to 2 to 4 sentences
- Use plain English, explain any legal terms in parentheses
- Be practical and calm, like a sharp lawyer friend
- Clearly say whether the answer is county, state, or federal specific
- If the law is uncertain or fact dependent, say that honestly
''';
    }
  }

  String _getStyleLabel(ResponseStyle style) {
    switch (style) {
      case ResponseStyle.quickCasual:
        return 'Quick & Casual';
      case ResponseStyle.detailed:
        return 'Detailed & Thorough';
      case ResponseStyle.justFacts:
        return 'Just the Facts';
      case ResponseStyle.explainLikeFive:
        return "Explain Like I'm 5";
      case ResponseStyle.standard:
      default:
        return 'Standard';
    }
  }

  String _getResponseSections(ResponseStyle style) {
    switch (style) {
      case ResponseStyle.quickCasual:
        return '''## Short answer
## What to do''';
      case ResponseStyle.justFacts:
        return '''## Answer
## Legal basis
## Scope''';
      case ResponseStyle.explainLikeFive:
        return '''## In simple terms
## Why it works this way
## What you can do''';
      case ResponseStyle.detailed:
      case ResponseStyle.standard:
      default:
        return '''## Short answer
## What this means
## What to do next
## Scope''';
    }
  }

  String _getResponseRequirements(ResponseStyle style, String name) {
    final disclaimer = "End with your signature disclaimer: \"I'm $name, your pocket lawyer — I help you understand the law in plain English. I'm not YOUR lawyer though, so for advice specific to your situation, talk to a licensed attorney in your area.\"";

    switch (style) {
      case ResponseStyle.quickCasual:
        return '''
- Keep it to 1-2 sentences max for the short answer
- Super casual tone, like explaining to a friend over coffee
- Focus on the practical takeaway
- $disclaimer
''';
      case ResponseStyle.justFacts:
        return '''
- Present facts objectively without conversational elements
- Cite specific statutes or case law when available
- Be precise and accurate
- Include a formal disclaimer
''';
      case ResponseStyle.explainLikeFive:
        return '''
- Use super simple words and comparisons
- Every legal term needs a simple analogy
- Be encouraging and warm
- $disclaimer
''';
      case ResponseStyle.detailed:
        return '''
- Cover all relevant angles comprehensively
- Cite specific statutes or case law naturally when available
- Provide thorough context and background
- $disclaimer
''';
      case ResponseStyle.standard:
      default:
        return '''
- Use plain English, explain any legal terms in parentheses
- Be practical and calm, like a sharp lawyer friend
- Cite specific statutes or case law naturally when available
- $disclaimer
''';
    }
  }

  List<String> _extractFollowUpSuggestions(String response) {
    final suggestions = <String>[];
    
    // Find the follow-up section
    final followUpSectionMatch = RegExp(
      r'## Suggested follow-up questions\s*\n+(.*?)(?=##\s|\Z)',
      dotAll: true,
    ).firstMatch(response);

    if (followUpSectionMatch != null) {
      final sectionContent = followUpSectionMatch.group(1) ?? '';
      
      // Extract bullet points
      final bulletMatches = RegExp(
        r'^[\-\*]\s+(.+)$',
        multiLine: true,
      ).allMatches(sectionContent);

      for (final match in bulletMatches) {
        final question = match.group(1)?.trim();
        if (question != null && question.isNotEmpty && question.length < 100) {
          // Clean up the question (remove quotes, extra formatting)
          var cleaned = question.replaceAll(RegExp("^['\"]|['\"]\$"), '');
          // Remove leading "Q:" or similar if present
          cleaned = cleaned.replaceFirst(RegExp(r'^[A-Za-z]{1,3}:\s*'), '');
          if (cleaned.isNotEmpty) {
            suggestions.add(cleaned);
          }
        }
        if (suggestions.length >= 3) break;
      }
    }

    return suggestions;
  }

  Future<String> generateConversationSummary(List<String> userQuestions, List<String> aiResponses) async {
    final conversationText = StringBuffer();
    
    for (int i = 0; i < userQuestions.length && i < aiResponses.length; i++) {
      conversationText.writeln('Q: ${userQuestions[i]}');
      conversationText.writeln('A: ${aiResponses[i].substring(0, aiResponses[i].length > 200 ? 200 : aiResponses[i].length)}...');
      conversationText.writeln();
    }

    final summaryPrompt = '''
Summarize this legal conversation into 3-5 bullet points. Focus on:
1. The main legal topics discussed
2. Key information provided
3. Any actions recommended

Keep each point to one sentence. Format as a bulleted list.

Conversation:
$conversationText
''';

    try {
      final result = await _legalService.comprehensiveLegalQuery(
        userQuery: 'Summarize this conversation',
        llmPrompt: summaryPrompt,
        jurisdiction: null,
        searchCaseLaw: false,
        searchStatutes: false,
        searchCongress: false,
      );
      return (result['ai_analysis'] as String?) ?? 'Unable to generate summary.';
    } catch (e) {
      return 'Summary unavailable: $e';
    }
  }
}

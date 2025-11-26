import 'package:flutter/foundation.dart';

import '../infrastructure/congress_api_client.dart';
import '../infrastructure/deepseek_api_client.dart';
import '../infrastructure/groq_api_client.dart';
import '../infrastructure/legiscan_api_client.dart';
import '../infrastructure/open_router_api_client.dart';

class ApiClientRepository {
  final OpenRouterApiClient _openRouterClient;
  final DeepSeekApiClient _deepSeekClient;
  final GroqApiClient _groqClient;
  final LegiScanApiClient _legiScanClient;
  final CongressApiClient _congressClient;

  ApiClientRepository(
    this._openRouterClient,
    this._deepSeekClient,
    this._groqClient,
    this._legiScanClient,
    this._congressClient,
  );

  /// Retrieve state statutes and regulations, augmented by LLM.
  /// Returns the raw LegiScan response with an added 'ai_summary' field when available.
  Future<Map<String, dynamic>> getStateLaws({
    required String state,
    required String legalTopic,
    String? searchQuery,
  }) async {
    try {
      final lawApiResponse = await _legiScanClient.getStateLaws(
        state: state,
        query: searchQuery != null ? '$legalTopic $searchQuery' : legalTopic,
      );
      final enriched = Map<String, dynamic>.from(lawApiResponse);
      
      final prompt = 'Based on the following data, provide a comprehensive summary of $legalTopic laws in $state: $lawApiResponse. Explain in simple terms, include relevant statutes, and cite sources.';
      
      try {
        final aiSummary = await _groqClient.generate(prompt: prompt);
        enriched['ai_summary'] = aiSummary;
      } catch (_) {
        try {
          final aiSummary = await _deepSeekClient.generate(prompt: prompt);
          enriched['ai_summary'] = aiSummary;
        } catch (_) {
          try {
            final aiSummary = await _openRouterClient.generate(prompt: prompt);
            enriched['ai_summary'] = aiSummary;
          } catch (e) {
            debugPrint('AI summary generation failed: $e');
          }
        }
      }
      return enriched;
    } catch (e) {
      // If structured API fails, fallback to pure LLM.
      final prompt =
          'Provide information on $legalTopic laws in $state${searchQuery != null ? ' regarding $searchQuery' : ''}. Include relevant statutes and cite sources.';
      
      try {
        final aiResponse = await _groqClient.generate(prompt: prompt);
        return {'ai_response': aiResponse, 'source': 'groq_fallback'};
      } catch (_) {
        try {
          final aiResponse = await _deepSeekClient.generate(prompt: prompt);
          return {'ai_response': aiResponse, 'source': 'deepseek_fallback'};
        } catch (_) {
          final aiResponse = await _openRouterClient.generate(prompt: prompt);
          return {'ai_response': aiResponse, 'source': 'openrouter_fallback'};
        }
      }
    }
  }

  /// Retrieve federal statutes and regulations, augmented by LLM.
  /// Returns the raw Congress.gov style response with an added 'ai_summary' field when available.
  Future<Map<String, dynamic>> getFederalLaws({
    required String legalTopic,
    String? searchQuery,
  }) async {
    try {
      final lawApiResponse = await _congressClient.searchLaws(
        query: searchQuery != null ? '$legalTopic $searchQuery' : legalTopic,
      );
      final enriched = Map<String, dynamic>.from(lawApiResponse);
      
      final prompt = 'Based on the following data, provide a comprehensive summary of federal $legalTopic laws: $lawApiResponse. Explain in simple terms, include relevant statutes, and cite sources.';
      
      try {
        final aiSummary = await _groqClient.generate(prompt: prompt);
        enriched['ai_summary'] = aiSummary;
      } catch (_) {
        try {
          final aiSummary = await _deepSeekClient.generate(prompt: prompt);
          enriched['ai_summary'] = aiSummary;
        } catch (_) {
          try {
            final aiSummary = await _openRouterClient.generate(prompt: prompt);
            enriched['ai_summary'] = aiSummary;
          } catch (e) {
            debugPrint('AI summary generation failed: $e');
          }
        }
      }
      return enriched;
    } catch (e) {
      // If structured API fails, fallback to pure LLM.
      final prompt =
          'Provide information on federal $legalTopic laws${searchQuery != null ? ' regarding $searchQuery' : ''}. Include relevant statutes and cite sources.';
      
      try {
        final aiResponse = await _groqClient.generate(prompt: prompt);
        return {'ai_response': aiResponse, 'source': 'groq_fallback'};
      } catch (_) {
        try {
          final aiResponse = await _deepSeekClient.generate(prompt: prompt);
          return {'ai_response': aiResponse, 'source': 'deepseek_fallback'};
        } catch (_) {
          final aiResponse = await _openRouterClient.generate(prompt: prompt);
          return {'ai_response': aiResponse, 'source': 'openrouter_fallback'};
        }
      }
    }
  }

  /// Search relevant court decisions and case law (simulated via AI).
  Future<Map<String, dynamic>> searchCaseLaw({
    required String jurisdiction,
    required String legalIssue,
    int maxResults = 5,
  }) async {
    final prompt =
        'Search for relevant court cases in $jurisdiction regarding $legalIssue. Provide up to $maxResults cases with citations and brief summaries.';
    
    try {
      final aiResponse = await _groqClient.generate(prompt: prompt);
      return {'ai_response': aiResponse, 'source': 'groq'};
    } catch (_) {
      try {
        final aiResponse = await _deepSeekClient.generate(prompt: prompt);
        return {'ai_response': aiResponse, 'source': 'deepseek'};
      } catch (_) {
        final aiResponse = await _openRouterClient.generate(prompt: prompt);
        return {'ai_response': aiResponse, 'source': 'openrouter'};
      }
    }
  }

  /// Retrieve specific law by citation or statute number, augmented by LLM.
  Future<Map<String, dynamic>> getSpecificCitation({
    required String citation,
    String? jurisdiction,
  }) async {
    try {
      if (jurisdiction == null) {
        final stateAbbreviations = ['CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI'];
        final matchedAbbr = stateAbbreviations.firstWhere((abbr) => citation.contains(abbr), orElse: () => '');
        if (matchedAbbr.isNotEmpty) {
          jurisdiction = matchedAbbr;
        } else {
          jurisdiction = 'federal';
        }
      }

      Map<String, dynamic> lawApiResponse;
      String apiSource;

      if (jurisdiction != 'federal') {
        lawApiResponse = await _legiScanClient.getStateLaws(state: jurisdiction, query: citation);
        apiSource = 'LegiScan';
      } else {
        lawApiResponse = await _congressClient.searchLaws(query: citation);
        apiSource = 'Congress.gov';
      }

      final enriched = Map<String, dynamic>.from(lawApiResponse);
      final prompt = 'Based on the following data from $apiSource, provide a detailed explanation of the law or citation "$citation": $lawApiResponse. Explain its meaning and implications in simple terms.';
      
      try {
        final aiSummary = await _groqClient.generate(prompt: prompt);
        enriched['ai_summary'] = aiSummary;
      } catch (_) {
        try {
          final aiSummary = await _deepSeekClient.generate(prompt: prompt);
          enriched['ai_summary'] = aiSummary;
        } catch (_) {
          try {
            final aiSummary = await _openRouterClient.generate(prompt: prompt);
            enriched['ai_summary'] = aiSummary;
          } catch (e) {
            debugPrint('AI summary generation failed: $e');
          }
        }
      }

      return enriched;
    } catch (e) {
      final prompt =
          'Provide the text and explanation of citation: $citation${jurisdiction != null ? ' from $jurisdiction' : ''}.';
      
      try {
        final aiResponse = await _groqClient.generate(prompt: prompt);
        return {'ai_response': aiResponse, 'source': 'groq_fallback'};
      } catch (_) {
        try {
          final aiResponse = await _deepSeekClient.generate(prompt: prompt);
          return {'ai_response': aiResponse, 'source': 'deepseek_fallback'};
        } catch (_) {
          final aiResponse = await _openRouterClient.generate(prompt: prompt);
          return {'ai_response': aiResponse, 'source': 'openrouter_fallback'};
        }
      }
    }
  }

  /// Legacy method names kept for backward compatibility.
  Future<String> queryOpenRouter(String prompt) => _openRouterClient.generate(prompt: prompt);
  Future<String> queryDeepSeek(String prompt) => _deepSeekClient.generate(prompt: prompt);
  Future<String> queryGroq(String prompt) => _groqClient.generate(prompt: prompt);
  Future<String> queryOpenAi(String prompt) => _groqClient.generate(prompt: prompt); // Redirect legacy OpenAI calls to Groq
}

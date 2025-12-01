// AUTO-GENERATED - Complete Legal AI Service with Law Libraries
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LegalAIService {
  final Dio _dio = Dio();

  // CourtListener - 8M+ court cases
  Future<Map> searchCases(String query) async {
    final response =
        await _dio.get('https://www.courtlistener.com/api/rest/v3/search/',
            options: Options(headers: {
              'Authorization':
                  'Token ${dotenv.env['COURTLISTENER_API_KEY'] ?? const String.fromEnvironment('COURTLISTENER_API_KEY')}'
            }),
            queryParameters: {'q': query, 'type': 'o'});
    return response.data;
  }

  // LegiScan - State legislation
  Future<Map> searchLegislation(String query) async {
    final response =
        await _dio.get('https://api.legiscan.com/', queryParameters: {
      'key': dotenv.env['LEGISCAN_API_KEY'] ??
          const String.fromEnvironment('LEGISCAN_API_KEY'),
      'op': 'getSearch',
      'query': query
    });
    return response.data;
  }

  // Congress.gov - Federal laws
  Future<Map> searchCongress(String query) async {
    final response = await _dio.get('https://api.congress.gov/v3/bill',
        options: Options(headers: {
          'X-Api-Key': dotenv.env['CONGRESS_GOV_API_KEY'] ??
              const String.fromEnvironment('CONGRESS_GOV_API_KEY')
        }),
        queryParameters: {'format': 'json', 'limit': 20});
    return response.data;
  }

  // OpenRouter AI Analysis
  Future<String> generateAnalysis(String query, Map legalData) async {
    final response =
        await _dio.post('https://openrouter.ai/api/v1/chat/completions',
            options: Options(headers: {
              'Authorization':
                  'Bearer ${dotenv.env['OPENROUTER_API_KEY'] ?? const String.fromEnvironment('OPENROUTER_API_KEY')}',
              'HTTP-Referer': 'https://pocketlawyer.ai'
            }),
            data: {
          'model': 'anthropic/claude-3-opus',
          'messages': [
            {'role': 'system', 'content': 'Legal expert analyzing: $legalData'},
            {'role': 'user', 'content': query}
          ]
        });
    return response.data['choices'][0]['message']['content'];
  }
}

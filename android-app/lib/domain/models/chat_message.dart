import 'legal_source.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<LegalSource>? sources;
  final double? confidence;
  final List<String>? followUpSuggestions;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.confidence,
    this.followUpSuggestions,
  });

  ChatMessage copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<LegalSource>? sources,
    double? confidence,
    List<String>? followUpSuggestions,
  }) {
    return ChatMessage(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
      confidence: confidence ?? this.confidence,
      followUpSuggestions: followUpSuggestions ?? this.followUpSuggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'sources': sources?.map((s) => s.toJson()).toList(),
      'confidence': confidence,
      'followUpSuggestions': followUpSuggestions,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sources: (json['sources'] as List?)
          ?.map((s) => LegalSource.fromJson(s as Map<String, dynamic>))
          .toList(),
      confidence: json['confidence'] as double?,
      followUpSuggestions: (json['followUpSuggestions'] as List?)
          ?.map((s) => s as String)
          .toList(),
    );
  }
}

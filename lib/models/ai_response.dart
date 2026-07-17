import 'citation.dart';

class AIResponse {
  final String answer;
  final String languageCode;
  final String mode;
  final String confidence;
  final List<Citation> citations;
  final String interpretationLabel;
  final List<String> limitations;

  AIResponse({
    required this.answer,
    required this.languageCode,
    required this.mode,
    required this.confidence,
    required this.citations,
    required this.interpretationLabel,
    required this.limitations,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      answer: json['answer'] ?? '',
      languageCode: json['languageCode'] ?? 'en',
      mode: json['mode'] ?? 'student',
      confidence: json['confidence'] ?? 'medium',
      citations: (json['citations'] as List? ?? [])
          .map((c) => Citation.fromJson(c as Map<String, dynamic>))
          .toList(),
      interpretationLabel: json['interpretationLabel'] ?? 'AI-generated explanation',
      limitations: List<String>.from(json['limitations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'languageCode': languageCode,
      'mode': mode,
      'confidence': confidence,
      'citations': citations.map((c) => c.toJson()).toList(),
      'interpretationLabel': interpretationLabel,
      'limitations': limitations,
    };
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_response.dart';

class AiService {
  // Read compilation-defined endpoint details
  static const String hfEndpoint = String.fromEnvironment(
    'SITARAM_HF_ENDPOINT',
    defaultValue: 'http://localhost:5500', // fallback to local mock server
  );
  
  static const String hfAppKey = String.fromEnvironment(
    'SITARAM_HF_APP_KEY',
    defaultValue: 'sitaram_secret_key_108',
  );

  static const String _geminiApiKeyPrefKey = 'gemini_api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyPrefKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyPrefKey, key);
  }

  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyPrefKey);
  }

  // Check if live AI is configured
  bool get isLiveConfigured {
    return hfEndpoint.isNotEmpty && hfEndpoint != 'http://localhost:5500';
  }

  // RAG query to Hugging Face FastAPI Space
  Future<AIResponse> askRAG({
    required String question,
    String languageCode = 'en',
    String mode = 'student',
    String? kandaId,
  }) async {
    if (!isLiveConfigured) {
      // Return simulated offline fallback response
      return _getSimulatedResponse(question, languageCode, mode, kandaId);
    }

    try {
      final url = Uri.parse('$hfEndpoint/ask');
      final body = {
        'question': question,
        'languageCode': languageCode,
        'mode': mode,
        'filters': kandaId != null ? {'kandaId': kandaId} : null,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-SitaRam-Key': hfAppKey,
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return AIResponse.fromJson(decoded);
      } else {
        throw Exception('API error: Code ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to offline content
      return _getSimulatedResponse(question, languageCode, mode, kandaId, isFallback: true);
    }
  }

  // Submit feedback to RAG backend
  Future<bool> submitFeedback({
    required String feedbackId,
    required String questionId,
    required String answerId,
    required String rating,
    required String reason,
    String comment = '',
    String reportedPassageId = '',
    String language = 'en',
  }) async {
    if (!isLiveConfigured) return true;

    try {
      final url = Uri.parse('$hfEndpoint/feedback');
      final body = {
        'feedbackId': feedbackId,
        'questionId': questionId,
        'answerId': answerId,
        'rating': rating,
        'reason': reason,
        'userComment': comment,
        'reportedPassageId': reportedPassageId,
        'language': language,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-SitaRam-Key': hfAppKey,
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Hybrid Search on HF endpoint
  Future<List<Map<String, dynamic>>> searchScripture(String query, {int limit = 5}) async {
    if (!isLiveConfigured) return [];

    try {
      final url = Uri.parse('$hfEndpoint/search');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-SitaRam-Key': hfAppKey,
        },
        body: json.encode({
          'query': query,
          'limit': limit,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  // Offline Simulation engine based on canonical assets
  AIResponse _getSimulatedResponse(
    String question,
    String languageCode,
    String mode,
    String? kandaId, {
    bool isFallback = false,
  }) {
    final q = question.toLowerCase();
    String answer = '';
    String label = isFallback
        ? 'Live AI is unavailable. This answer uses approved offline SitaRam content.'
        : 'Offline mode: displaying local reference data.';
        
    // Generate simple localized answers matching common topics
    if (q.contains('simply') || q.contains('explain')) {
      answer = 'Sri Rama is the central figure of the Valmiki Ramayana, representing the ideal human (Maryada Purushottama) who always acts according to duty (dharma).';
    } else if (q.contains('moral') || q.contains('lesson')) {
      answer = 'Upholding parent vows, loyalty to family, and righteousness in the face of temporary gain stand out as the primary ethical tenets of the epic.';
    } else {
      answer = 'Valmiki Ramayana depicts Rama’s exile, Hanuman’s leap of faith, Ravana’s defeat, and the ultimate restoration of Dharma in Ayodhya.';
    }

    if (languageCode == 'bn') {
      answer = 'শ্রীরামচন্দ্র হলেন আদর্শ মানুষ ও ধর্মের মূর্ত প্রতীক। তিনি সর্বদা পিতার আদেশ ও সত্য রক্ষায় প্রতিজ্ঞাবদ্ধ ছিলেন।';
    } else if (languageCode == 'es') {
      answer = 'Rama representa el ser humano ideal que siempre actúa de acuerdo con el deber (dharma), priorizando el honor sobre el poder.';
    }

    return AIResponse(
      answer: answer,
      languageCode: languageCode,
      mode: mode,
      confidence: 'low',
      // No retrieval happens offline, so there is no passage to cite. Emitting a
      // citation here would attribute an unverified quotation to a source edition
      // that was never consulted.
      citations: const [],
      interpretationLabel: label,
      limitations: const [
        'Generated locally without a network connection.',
        'Not grounded in any retrieved source passage — this is a general summary, not scripture.',
        'No edition, translator, or Sarga can be cited for this response.',
      ],
    );
  }
}

// Riverpod Providers
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final geminiApiKeyProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.getApiKey();
});

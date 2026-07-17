import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chapter.dart';

class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _geminiApiKeyPrefKey = 'gemini_api_key';

  /// The mobile app never stores a Hugging Face token. Instead, it calls a
  /// small SitaRam backend deployed as a Hugging Face Docker Space.
  ///
  /// Configure release builds with:
  /// --dart-define=SITARAM_HF_ENDPOINT=https://YOUR-SPACE.hf.space
  /// --dart-define=SITARAM_HF_APP_KEY=YOUR_OPTIONAL_APP_KEY
  static const String huggingFaceEndpoint = String.fromEnvironment(
    'SITARAM_HF_ENDPOINT',
    defaultValue: '',
  );
  static const String huggingFaceAppKey = String.fromEnvironment(
    'SITARAM_HF_APP_KEY',
    defaultValue: '',
  );

  bool get isHuggingFaceConfigured => huggingFaceEndpoint.trim().isNotEmpty;

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyPrefKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyPrefKey, key.trim());
  }

  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyPrefKey);
  }

  String buildContextPrompt(
    Chapter chapter,
    String userQuestion,
    String? selectedPassage, {
    String languageCode = 'en',
  }) {
    final langInstruction = switch (languageCode) {
      'bn' => 'Always respond in Bengali (Bangla) using বাংলা script.',
      'es' => 'Always respond in Spanish (Español).',
      _ => 'Respond in English unless the user clearly asks for Bengali or Spanish.',
    };

    return '''
You are SitaRam AI, a respectful educational guide to the Valmiki Ramayana.

SAFETY AND SOURCE RULES
- This guide supports learning and reflection; it is not a religious authority.
- Use the supplied approved chapter material as the primary source.
- Never invent a Sanskrit verse, verse number, quotation, genealogy, location,
  or event that is not present in the supplied material.
- Clearly say when the supplied chapter does not contain enough evidence.
- Distinguish source-based explanation from general background knowledge.
- Cite the chapter title, Kanda, chapter number, and source title.
- $langInstruction

APPROVED CHAPTER CONTEXT
Kanda: ${chapter.kanda}
Chapter: ${chapter.chapterNumber}
English title: ${chapter.chapterTitleEnglish}
Bangla title: ${chapter.chapterTitleBangla}
Spanish title: ${chapter.chapterTitleSpanish}
English text: ${chapter.englishText}
Bangla text: ${chapter.banglaText}
Spanish text: ${chapter.spanishText}
English summary: ${chapter.shortSummaryEnglish}
Bangla summary: ${chapter.shortSummaryBangla}
Spanish summary: ${chapter.shortSummarySpanish}
English lesson: ${chapter.moralLessonEnglish}
Bangla lesson: ${chapter.moralLessonBangla}
Spanish lesson: ${chapter.moralLessonSpanish}
Characters: ${chapter.characters.join(', ')}
Themes: ${chapter.themes.join(', ')}
Source: ${chapter.sourceTitle}
Source status: ${chapter.sourceStatus}
Review status: ${chapter.reviewStatus}
Selected passage: ${selectedPassage ?? '[No passage selected]'}

USER QUESTION
$userQuestion
''';
  }

  /// Provider order:
  /// 1. Owner-managed Hugging Face Space (no user API key required)
  /// 2. Optional Gemini key supplied by an advanced user
  /// 3. Fully offline, source-grounded explanation
  Future<String> askAi(
    Chapter chapter,
    String question, {
    String? selectedPassage,
    String languageCode = 'en',
  }) async {
    final prompt = buildContextPrompt(
      chapter,
      question,
      selectedPassage,
      languageCode: languageCode,
    );

    if (isHuggingFaceConfigured) {
      try {
        return await _askHuggingFace(
          chapter: chapter,
          question: question,
          selectedPassage: selectedPassage,
          languageCode: languageCode,
        );
      } catch (_) {
        // Continue to the next provider. End users should still receive a
        // useful answer when the Space is sleeping or temporarily unavailable.
      }
    }

    final geminiApiKey = await getApiKey();
    if (geminiApiKey != null && geminiApiKey.trim().isNotEmpty) {
      try {
        return await _askGemini(prompt, geminiApiKey.trim());
      } catch (_) {
        // Continue to the offline source-grounded response.
      }
    }

    return _getOfflineResponse(
      chapter,
      question,
      languageCode: languageCode,
    );
  }

  Future<String> _askHuggingFace({
    required Chapter chapter,
    required String question,
    required String languageCode,
    String? selectedPassage,
  }) async {
    final base = huggingFaceEndpoint.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$base/ask');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (huggingFaceAppKey.trim().isNotEmpty)
        'X-SitaRam-Key': huggingFaceAppKey.trim(),
    };

    final response = await _client
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'question': question,
            'language_code': languageCode,
            'selected_passage': selectedPassage,
            'chapter': {
              'id': chapter.id,
              'kanda': chapter.kanda,
              'chapter_number': chapter.chapterNumber,
              'title_en': chapter.chapterTitleEnglish,
              'title_bn': chapter.chapterTitleBangla,
              'title_es': chapter.chapterTitleSpanish,
              'text_en': chapter.englishText,
              'text_bn': chapter.banglaText,
              'text_es': chapter.spanishText,
              'summary_en': chapter.shortSummaryEnglish,
              'summary_bn': chapter.shortSummaryBangla,
              'summary_es': chapter.shortSummarySpanish,
              'lesson_en': chapter.moralLessonEnglish,
              'lesson_bn': chapter.moralLessonBangla,
              'lesson_es': chapter.moralLessonSpanish,
              'characters': chapter.characters,
              'themes': chapter.themes,
              'source_title': chapter.sourceTitle,
              'source_status': chapter.sourceStatus,
              'review_status': chapter.reviewStatus,
            },
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw StateError('SitaRam AI backend returned ${response.statusCode}.');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected SitaRam AI response.');
    }

    final answer = data['answer']?.toString().trim() ?? '';
    if (answer.isEmpty) {
      throw const FormatException('SitaRam AI returned an empty answer.');
    }
    return answer;
  }

  Future<String> _askGemini(String prompt, String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.2,
              'maxOutputTokens': 900,
            },
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw StateError('Gemini returned ${response.statusCode}.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    final parts = candidates?.isNotEmpty == true
        ? candidates!.first['content']?['parts'] as List?
        : null;
    final answer = parts?.isNotEmpty == true
        ? parts!.first['text']?.toString().trim() ?? ''
        : '';

    if (answer.isEmpty) {
      throw const FormatException('Gemini returned an empty answer.');
    }
    return answer;
  }

  String _getOfflineResponse(
    Chapter chapter,
    String question, {
    required String languageCode,
  }) {
    final q = question.toLowerCase();
    final wantsCharacters = q.contains('character') || q.contains('চরিত্র');
    final wantsLesson = q.contains('moral') ||
        q.contains('lesson') ||
        q.contains('নৈতিক') ||
        q.contains('শিক্ষা');
    final wantsChild = q.contains('child') || q.contains('শিশু');

    if (languageCode == 'bn' || _hasBanglaCharacters(question)) {
      final summary = chapter.shortSummaryBangla.isNotEmpty
          ? chapter.shortSummaryBangla
          : chapter.banglaText;
      final focus = wantsCharacters
          ? 'প্রধান চরিত্র: ${chapter.characters.join(', ')}।'
          : wantsLesson
              ? 'মূল শিক্ষা: ${chapter.moralLessonBangla}'
              : wantsChild
                  ? 'সহজভাবে: $summary'
                  : summary;
      return '''
$focus

বিষয়: ${chapter.themes.join(', ')}
উৎস: ${chapter.sourceTitle} — ${chapter.kanda}, অধ্যায় ${chapter.chapterNumber}, “${chapter.chapterTitleBangla}”

সীতারাম এআই শেখা ও ভাবনার সহায়ক; এটি ধর্মীয় কর্তৃপক্ষ নয়। অনলাইন এআই সাময়িকভাবে অনুপলব্ধ হলে এই যাচাইকৃত অফলাইন তথ্য দেখানো হয়।''';
    }

    if (languageCode == 'es') {
      final summary = chapter.shortSummarySpanish.isNotEmpty
          ? chapter.shortSummarySpanish
          : chapter.shortSummaryEnglish;
      final lesson = chapter.moralLessonSpanish.isNotEmpty
          ? chapter.moralLessonSpanish
          : chapter.moralLessonEnglish;
      final focus = wantsCharacters
          ? 'Personajes principales: ${chapter.characters.join(', ')}.'
          : wantsLesson
              ? 'Lección principal: $lesson'
              : wantsChild
                  ? 'Explicación sencilla: $summary'
                  : summary;
      return '''
$focus

Temas: ${chapter.themes.join(', ')}
Fuente: ${chapter.sourceTitle} — ${chapter.kanda}, capítulo ${chapter.chapterNumber}, “${chapter.chapterTitleEnglish}”

SitaRam AI es una guía educativa, no una autoridad religiosa. Esta respuesta verificada sin conexión aparece cuando la IA en vivo no está disponible.''';
    }

    final focus = wantsCharacters
        ? 'Main characters: ${chapter.characters.join(', ')}.'
        : wantsLesson
            ? 'Core lesson: ${chapter.moralLessonEnglish}'
            : wantsChild
                ? 'Simple explanation: ${chapter.shortSummaryEnglish}'
                : chapter.shortSummaryEnglish;

    return '''
$focus

Themes: ${chapter.themes.join(', ')}
Source: ${chapter.sourceTitle} — ${chapter.kanda}, chapter ${chapter.chapterNumber}, “${chapter.chapterTitleEnglish}”

SitaRam AI supports education and reflection; it is not a religious authority. This verified offline answer is shown when live AI is unavailable.''';
  }

  bool _hasBanglaCharacters(String text) {
    for (final rune in text.runes) {
      if (rune >= 0x0980 && rune <= 0x09FF) return true;
    }
    return false;
  }
}

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final geminiApiKeyProvider = FutureProvider<String?>((ref) async {
  return ref.watch(aiServiceProvider).getApiKey();
});

final huggingFaceConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(aiServiceProvider).isHuggingFaceConfigured;
});

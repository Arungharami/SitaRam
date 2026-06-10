import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chapter.dart';

class ContentService {
  List<Chapter> _chapters = [];

  List<Chapter> get chapters => _chapters;

  Future<List<Chapter>> loadChapters() async {
    if (_chapters.isNotEmpty) return _chapters;
    try {
      final String jsonString = await rootBundle.loadString('assets/content/ramayana_chapters.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _chapters = jsonList.map((e) => Chapter.fromJson(e)).toList();
      return _chapters;
    } catch (e) {
      print("Error loading chapters from assets: $e");
      return [];
    }
  }

  // Multi-index Search function
  List<Chapter> search({
    String query = '',
    String? kandaFilter,
    String? characterFilter,
    String? themeFilter,
    String? categoryFilter, // 'All', 'Characters', 'Themes', 'Kandas', 'Lessons', 'Bangla'
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _chapters.where((chapter) {
      // 1. Kanda Filter (from filter chips or direct parameter)
      if (kandaFilter != null && kandaFilter.isNotEmpty) {
        if (chapter.kanda.toLowerCase() != kandaFilter.toLowerCase() &&
            chapter.kandaId.toLowerCase() != kandaFilter.toLowerCase()) {
          return false;
        }
      }

      // 2. Character Filter
      if (characterFilter != null && characterFilter.isNotEmpty) {
        final match = chapter.characters.any((c) => c.toLowerCase() == characterFilter.toLowerCase());
        if (!match) return false;
      }

      // 3. Theme Filter
      if (themeFilter != null && themeFilter.isNotEmpty) {
        final match = chapter.themes.any((t) => t.toLowerCase() == themeFilter.toLowerCase());
        if (!match) return false;
      }

      // 4. Text Query Match
      if (cleanQuery.isNotEmpty) {
        // Narrow search scope depending on search category filter (Priority 5)
        if (categoryFilter == 'Characters') {
          return chapter.characters.any((c) => c.toLowerCase().contains(cleanQuery));
        } else if (categoryFilter == 'Themes') {
          return chapter.themes.any((t) => t.toLowerCase().contains(cleanQuery));
        } else if (categoryFilter == 'Kandas') {
          return chapter.kanda.toLowerCase().contains(cleanQuery);
        } else if (categoryFilter == 'Lessons') {
          return chapter.moralLessonEnglish.toLowerCase().contains(cleanQuery) ||
                 chapter.moralLessonBangla.toLowerCase().contains(cleanQuery);
        } else if (categoryFilter == 'Bangla') {
          return chapter.chapterTitleBangla.toLowerCase().contains(cleanQuery) ||
                 chapter.banglaText.toLowerCase().contains(cleanQuery) ||
                 chapter.shortSummaryBangla.toLowerCase().contains(cleanQuery);
        }

        // Default: search all fields
        final titleMatch = chapter.chapterTitleEnglish.toLowerCase().contains(cleanQuery);
        final titleBnMatch = chapter.chapterTitleBangla.toLowerCase().contains(cleanQuery);
        final kandaMatch = chapter.kanda.toLowerCase().contains(cleanQuery);
        
        final textMatch = chapter.englishText.toLowerCase().contains(cleanQuery);
        final bnTextMatch = chapter.banglaText.toLowerCase().contains(cleanQuery);
        
        final summaryMatch = chapter.shortSummaryEnglish.toLowerCase().contains(cleanQuery);
        final summaryBnMatch = chapter.shortSummaryBangla.toLowerCase().contains(cleanQuery);
        
        final lessonMatch = chapter.moralLessonEnglish.toLowerCase().contains(cleanQuery) ||
                            chapter.moralLessonBangla.toLowerCase().contains(cleanQuery);
        
        final charMatch = chapter.characters.any((c) => c.toLowerCase().contains(cleanQuery));
        final themeMatch = chapter.themes.any((t) => t.toLowerCase().contains(cleanQuery));

        return titleMatch || titleBnMatch || kandaMatch || textMatch || bnTextMatch ||
               summaryMatch || summaryBnMatch || lessonMatch || charMatch || themeMatch;
      }

      return true;
    }).toList();
  }

  // Get distinct list of Kandas
  List<String> getKandas() {
    return _chapters.map((c) => c.kanda).toSet().toList();
  }

  // Get distinct list of Characters
  List<String> getCharacters() {
    return _chapters.expand((c) => c.characters).toSet().toList();
  }

  // Get distinct list of Themes
  List<String> getThemes() {
    return _chapters.expand((c) => c.themes).toSet().toList();
  }
}

// Riverpod Providers
final contentServiceProveder = Provider<ContentService>((ref) {
  return ContentService();
});

final chaptersListProvider = FutureProvider<List<Chapter>>((ref) async {
  final service = ref.watch(contentServiceProveder);
  return await service.loadChapters();
});

// Active chapter state provider (for syncing across screens/tabs)
final activeChapterProvider = StateProvider<Chapter?>((ref) => null);

// Search states
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedKandaProvider = StateProvider<String?>((ref) => null);
final selectedCharacterProvider = StateProvider<String?>((ref) => null);
final selectedThemeProvider = StateProvider<String?>((ref) => null);
final searchCategoryFilterProvider = StateProvider<String>((ref) => 'All'); // All, Characters, Themes, Kandas, Lessons, Bangla

// Computed Search Results Provider
final searchResultsProvider = Provider<List<Chapter>>((ref) {
  final service = ref.watch(contentServiceProveder);
  final chaptersAsync = ref.watch(chaptersListProvider);
  
  final query = ref.watch(searchQueryProvider);
  final selectedKanda = ref.watch(selectedKandaProvider);
  final selectedCharacter = ref.watch(selectedCharacterProvider);
  final selectedTheme = ref.watch(selectedThemeProvider);
  final categoryFilter = ref.watch(searchCategoryFilterProvider);

  return chaptersAsync.maybeWhen(
    data: (list) {
      return service.search(
        query: query,
        kandaFilter: selectedKanda,
        characterFilter: selectedCharacter,
        themeFilter: selectedTheme,
        categoryFilter: categoryFilter == 'All' ? null : categoryFilter,
      );
    },
    orElse: () => [],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/content_service.dart';
import '../models/chapter.dart';
import '../theme.dart';
import 'reader_screen.dart';

class ResearchDashboard extends ConsumerStatefulWidget {
  const ResearchDashboard({super.key});

  @override
  ConsumerState<ResearchDashboard> createState() => _ResearchDashboardState();
}

class _ResearchDashboardState extends ConsumerState<ResearchDashboard> {
  final TextEditingController _notesController = TextEditingController();
  static const String _reflectionNotesKey = 'sitaram_reflection_notes';
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNotes();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getString(_reflectionNotesKey) ?? '';
    if (mounted) {
      setState(() {
        _notesController.text = notes;
      });
    }
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isSavingNotes = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reflectionNotesKey, _notesController.text.trim());
    if (mounted) {
      setState(() {
        _isSavingNotes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.saffronPrimary,
          content: Text('Your scriptural reflection notes have been saved locally.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final selectedKanda = ref.watch(selectedKandaProvider);
    final selectedChar = ref.watch(selectedCharacterProvider);
    final selectedTheme = ref.watch(selectedThemeProvider);
    final activeFilter = ref.watch(searchCategoryFilterProvider);
    final searchResults = ref.watch(searchResultsProvider);

    final isSearching = query.isNotEmpty || selectedKanda != null || selectedChar != null || selectedTheme != null;

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      appBar: AppBar(
        title: const Text('Research & Study Mode'),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search characters, themes, moral lessons, text...',
                hintStyle: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppTheme.goldAccent),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textDimMaroon),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(selectedKandaProvider.notifier).state = null;
                          ref.read(selectedCharacterProvider.notifier).state = null;
                          ref.read(selectedThemeProvider.notifier).state = null;
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.templeObsidian,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.goldAccent),
                ),
              ),
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: query,
                  selection: TextSelection.collapsed(offset: query.length),
                ),
              ),
            ),
          ),

          // 2. Filter Category Chips (Priority 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['All', 'Characters', 'Themes', 'Kandas', 'Lessons', 'Bangla'].map((cat) {
                final isSelected = activeFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(searchCategoryFilterProvider.notifier).state = cat;
                    },
                    selectedColor: AppTheme.saffronPrimary.withOpacity(0.2),
                    checkmarkColor: AppTheme.saffronPrimary,
                    backgroundColor: AppTheme.cardBgMaroon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? AppTheme.saffronPrimary : Colors.white10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(color: Colors.white10),

          // 3. Search Results vs Dashboard Mode
          Expanded(
            child: isSearching
                ? _buildSearchResultsView(searchResults, query)
                : _buildDashboardDefaultView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView(List<Chapter> results, String query) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 50, color: AppTheme.textDimMaroon),
              const SizedBox(height: 12),
              const Text('No Matches Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                'Try adjusting your keywords or clearing the filter chips.',
                style: TextStyle(color: AppTheme.textDimMaroon, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chapter = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ref.read(activeChapterProvider.notifier).state = chapter;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReaderScreen(chapter: chapter),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chapter.kanda.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: AppTheme.saffronPrimary, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      Text(
                        'Chapter ${chapter.chapterNumber}',
                        style: TextStyle(fontSize: 10, color: AppTheme.textDimMaroon),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chapter.chapterTitleEnglish,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.softCreamText),
                  ),
                  Text(
                    chapter.chapterTitleBangla,
                    style: const TextStyle(fontSize: 13, color: AppTheme.goldAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chapter.shortSummaryEnglish,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: AppTheme.textDimMaroon),
                  ),
                  const SizedBox(height: 12),
                  // Tags row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...chapter.characters.map((c) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(c, style: const TextStyle(fontSize: 9, color: AppTheme.goldAccent)),
                        )),
                        ...chapter.themes.map((t) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('#$t', style: const TextStyle(fontSize: 9, color: Colors.tealAccent)),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardDefaultView() {
    final characters = ['Rama', 'Sita', 'Hanuman', 'Valmiki', 'Lakshmana', 'Narada', 'Ravana', 'Brahma'];
    final themes = ['dharma', 'virtue', 'truth', 'compassion', 'poetry', 'devotion', 'faith', 'sacrifice'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme exploration
          Text(
            'Explore Themes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.goldAccent),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              return InkWell(
                onTap: () {
                  ref.read(selectedThemeProvider.notifier).state = theme;
                  ref.read(searchQueryProvider.notifier).state = theme;
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBgMaroon,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    '#$theme',
                    style: const TextStyle(fontSize: 12, color: AppTheme.softCreamText, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Character exploration
          Text(
            'Explore Characters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.goldAccent),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: characters.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () {
                      ref.read(selectedCharacterProvider.notifier).state = c;
                      ref.read(searchQueryProvider.notifier).state = c;
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppTheme.saffronPrimary.withOpacity(0.15),
                            child: Text(c[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(c, style: const TextStyle(fontSize: 11, color: AppTheme.softCreamText)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Saved Research/Reflection Notes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.devotionalCardDecoration(borderColor: Colors.white10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: AppTheme.goldAccent, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Saved Reflection Logs',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.softCreamText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Write down your notes, insights, or scriptural logs as you study. Saved locally on your device.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 13, color: AppTheme.softCreamText),
                  decoration: InputDecoration(
                    hintText: 'Type your reflection notes here...',
                    hintStyle: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.templeObsidian,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.saffronPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isSavingNotes ? null : _saveNotes,
                    icon: _isSavingNotes
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save_rounded, size: 14),
                    label: const Text('Save Note', style: TextStyle(fontSize: 12)),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Ask AI about this topic quick link
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.lotusCardDecoration(),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppTheme.goldAccent, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need Deeper Scriptural Insights?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.softCreamText),
                      ),
                      Text(
                        'Ask our AI Guide to analyze character motifs, moral structures, or historical context.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textDimMaroon),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppTheme.saffronPrimary),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  onPressed: () {
                    // Quick dialog or suggestion to direct users to AI tab
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Swipe or tap the "AI Guide" bottom tab to open the research assistant.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

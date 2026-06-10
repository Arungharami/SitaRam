import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/content_service.dart';
import '../theme.dart';
import 'reader_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Complete list of Kandas in Valmiki Ramayana
  static const List<Map<String, String>> kandaList = [
    {
      'id': 'bala_kanda',
      'name': 'Bala Kanda',
      'desc': 'Book of Youth - The birth, youth, and education of Sri Rama, and his holy marriage to Sita.',
      'gradient': 'bala'
    },
    {
      'id': 'ayodhya_kanda',
      'name': 'Ayodhya Kanda',
      'desc': 'Book of Ayodhya - The preparation for Rama\'s coronation, the boons of Kaikeyi, and the sorrowful exile.',
      'gradient': 'ayodhya'
    },
    {
      'id': 'aranya_kanda',
      'name': 'Aranya Kanda',
      'desc': 'Book of Forest - The forest life, encounters with sages and demons, and abduction of Sita by Ravana.',
      'gradient': 'aranya'
    },
    {
      'id': 'kishkindha_kanda',
      'name': 'Kishkindha Kanda',
      'desc': 'Book of Kishkindha - The alliance of Rama with Sugriva, the monkey kingdom, and launching the search.',
      'gradient': 'kishkindha'
    },
    {
      'id': 'sundara_kanda',
      'name': 'Sundara Kanda',
      'desc': 'Book of Beauty - Hanuman\'s miraculous flight to Lanka, locating Sita, and the burning of Lanka.',
      'gradient': 'sundara'
    },
    {
      'id': 'yuddha_kanda',
      'name': 'Yuddha Kanda',
      'desc': 'Book of War - The construction of the bridge (Setu), the great battle with Ravana, and rescue of Sita.',
      'gradient': 'yuddha'
    },
    {
      'id': 'uttara_kanda',
      'name': 'Uttara Kanda',
      'desc': 'Last Book - The return to Ayodhya, coronation of Sri Rama, and final pastimes.',
      'gradient': 'uttara'
    },
  ];

  LinearGradient _getKandaGradient(String type) {
    switch (type) {
      case 'bala':
        return const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFFFB300)]);
      case 'ayodhya':
        return const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFF8F00)]);
      case 'aranya':
        return const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF81C784)]);
      case 'kishkindha':
        return const LinearGradient(colors: [Color(0xFF0277BD), Color(0xFF29B6F6)]);
      case 'sundara':
        return const LinearGradient(colors: [Color(0xFFD81B60), Color(0xFFF48FB1)]);
      case 'yuddha':
        return const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFEF5350)]);
      case 'uttara':
        return const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFBA68C8)]);
      default:
        return AppTheme.saffronGoldGradient;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersListProvider);

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      body: Stack(
        children: [
          // Devotional Background pattern simulation (gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.templeGradient,
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Devotional Header
                SliverAppBar(
                  expandedHeight: 140.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.maroonBg.withOpacity(0.9),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.brightness_5_rounded, color: AppTheme.goldAccent, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          'SITARAM',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Chapter list content
                chaptersAsync.when(
                  data: (chapters) {
                    if (chapters.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 48, color: AppTheme.goldAccent),
                              SizedBox(height: 16),
                              Text('No Chapters Imported Yet', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final kanda = kandaList[index];
                            final kandaChapters = chapters
                                .where((ch) => ch.kandaId.toLowerCase() == kanda['id']!.toLowerCase())
                                .toList();
                                
                            return _buildDevotionalKandaCard(context, ref, kanda, kandaChapters);
                          },
                          childCount: kandaList.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.saffronPrimary),
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevotionalKandaCard(
    BuildContext context, 
    WidgetRef ref, 
    Map<String, String> kanda, 
    List<dynamic> kandaChapters
  ) {
    final hasChapters = kandaChapters.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: hasChapters 
          ? AppTheme.lotusCardDecoration() 
          : AppTheme.devotionalCardDecoration(borderColor: Colors.white10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppTheme.goldAccent,
          collapsedIconColor: AppTheme.textDimMaroon,
          title: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _getKandaGradient(kanda['gradient']!),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  kanda['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.softCreamText,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 26.0, top: 4.0),
            child: Text(
              '${kandaChapters.length} Chapter${kandaChapters.length == 1 ? '' : 's'} loaded',
              style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                kanda['desc']!,
                style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon, fontStyle: FontStyle.italic),
              ),
            ),
            if (kandaChapters.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'This Kanda is not yet compiled.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kandaChapters.length,
                itemBuilder: (context, chIdx) {
                  final ch = kandaChapters[chIdx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.saffronPrimary.withOpacity(0.2),
                      child: Text(
                        '${ch.chapterNumber}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.saffronPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      ch.chapterTitleEnglish,
                      style: const TextStyle(fontSize: 14, color: AppTheme.softCreamText, fontWeight: FontWeight.w500),
                    ),
                    subtitle: ch.chapterTitleBangla.isNotEmpty
                        ? Text(ch.chapterTitleBangla, style: const TextStyle(fontSize: 12, color: AppTheme.goldAccent))
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.textDimMaroon),
                    onTap: () {
                      // 1. Sync globally active chapter context
                      ref.read(activeChapterProvider.notifier).state = ch;
                      // 2. Push to reader screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(chapter: ch),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../services/content_service.dart';
import '../theme.dart';
import 'reader_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Map<String, String>> _kandaIds = [
    {'id': 'bala_kanda', 'gradient': 'bala'},
    {'id': 'ayodhya_kanda', 'gradient': 'ayodhya'},
    {'id': 'aranya_kanda', 'gradient': 'aranya'},
    {'id': 'kishkindha_kanda', 'gradient': 'kishkindha'},
    {'id': 'sundara_kanda', 'gradient': 'sundara'},
    {'id': 'yuddha_kanda', 'gradient': 'yuddha'},
    {'id': 'uttara_kanda', 'gradient': 'uttara'},
  ];

  String _getKandaName(AppLocalizations l10n, String id) {
    switch (id) {
      case 'bala_kanda': return l10n.kandaNameBala;
      case 'ayodhya_kanda': return l10n.kandaNameAyodhya;
      case 'aranya_kanda': return l10n.kandaNameAranya;
      case 'kishkindha_kanda': return l10n.kandaNameKishkindha;
      case 'sundara_kanda': return l10n.kandaNameSundara;
      case 'yuddha_kanda': return l10n.kandaNameYuddha;
      case 'uttara_kanda': return l10n.kandaNameUttara;
      default: return id;
    }
  }

  String _getKandaDesc(AppLocalizations l10n, String id) {
    switch (id) {
      case 'bala_kanda': return l10n.kandaDescBala;
      case 'ayodhya_kanda': return l10n.kandaDescAyodhya;
      case 'aranya_kanda': return l10n.kandaDescAranya;
      case 'kishkindha_kanda': return l10n.kandaDescKishkindha;
      case 'sundara_kanda': return l10n.kandaDescSundara;
      case 'yuddha_kanda': return l10n.kandaDescYuddha;
      case 'uttara_kanda': return l10n.kandaDescUttara;
      default: return '';
    }
  }

  LinearGradient _getKandaGradient(String type) {
    switch (type) {
      case 'bala': return const LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFFFB300)]);
      case 'ayodhya': return const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFF8F00)]);
      case 'aranya': return const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF81C784)]);
      case 'kishkindha': return const LinearGradient(colors: [Color(0xFF0277BD), Color(0xFF29B6F6)]);
      case 'sundara': return const LinearGradient(colors: [Color(0xFFD81B60), Color(0xFFF48FB1)]);
      case 'yuddha': return const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFEF5350)]);
      case 'uttara': return const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFBA68C8)]);
      default: return AppTheme.saffronGoldGradient;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final chaptersAsync = ref.watch(chaptersListProvider);

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.templeGradient)),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.maroonBg.withValues(alpha: 0.9),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.brightness_5_rounded, color: AppTheme.goldAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              l10n.homeTitle,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          l10n.homeTagline,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                            fontSize: 9,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                chaptersAsync.when(
                  data: (chapters) {
                    if (chapters.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 48, color: AppTheme.goldAccent),
                              const SizedBox(height: 16),
                              Text(l10n.homeNoChaptersImported,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            final kanda = _kandaIds[index];
                            final id = kanda['id']!;
                            final kandaChapters = chapters
                                .where((ch) => ch.kandaId.toLowerCase() == id.toLowerCase())
                                .toList();
                            return _buildKandaCard(context, ref, l10n, kanda, kandaChapters);
                          },
                          childCount: _kandaIds.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.saffronPrimary)),
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

  Widget _buildKandaCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Map<String, String> kanda,
    List<dynamic> kandaChapters,
  ) {
    final id = kanda['id']!;
    final hasChapters = kandaChapters.isNotEmpty;
    final name = _getKandaName(l10n, id);
    final desc = _getKandaDesc(l10n, id);

    return Material(
      color: Colors.transparent,
      child: Container(
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
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.softCreamText),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 26.0, top: 4.0),
            child: Text(
              l10n.homeChaptersLoaded(kandaChapters.length),
              style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                desc,
                style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon, fontStyle: FontStyle.italic),
              ),
            ),
            if (kandaChapters.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  l10n.homeNotYetCompiled,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kandaChapters.length,
                itemBuilder: (context, chIdx) {
                  final ch = kandaChapters[chIdx];
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.saffronPrimary.withValues(alpha: 0.2),
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
                      ref.read(activeChapterProvider.notifier).state = ch;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReaderScreen(chapter: ch)),
                      );
                    },
                  ),
                  );
                },
              ),
          ],
        ),
      ),
    ),
    );
  }
}

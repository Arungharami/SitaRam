import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/content_service.dart';
import '../theme.dart';
import 'donation_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Displaying modal disclaimer dialogs
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBgMaroon,
          title: Text(title, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(content, style: const TextStyle(color: AppTheme.softCreamText, fontSize: 13, height: 1.5)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppTheme.saffronPrimary)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final coverageAsync = ref.watch(coverageReportProvider);

    final languages = [
      {'code': 'en', 'native': 'English'},
      {'code': 'bn', 'native': 'বাংলা'},
      {'code': 'es', 'native': 'Español'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(l10n.settingsLanguage),
          Container(
            decoration: AppTheme.devotionalCardDecoration(),
            child: Column(
              children: languages.map((lang) {
                final isSelected = currentLocale.languageCode == lang['code'];
                return ListTile(
                  title: Text(
                    lang['native']!,
                    style: TextStyle(
                      color: isSelected ? AppTheme.goldAccent : AppTheme.softCreamText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.goldAccent)
                      : const Icon(Icons.circle_outlined, color: AppTheme.textDimMaroon),
                  onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(lang['code']!)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Real-time Corpus Coverage status
          _sectionHeader('CORPUS COVERAGE STATUS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.devotionalCardDecoration(),
            child: coverageAsync.when(
              data: (report) {
                final imported = report['sargasImported'] ?? 0;
                final expected = report['sargasExpected'] ?? 645;
                final verified = report['sargasTextVerified'] ?? 0;
                final pct = report['languages']?[currentLocale.languageCode]?['coveragePercent'] ?? 0.0;
                // Edition provenance is read from the generated coverage report, never
                // hardcoded: no edition may be credited until a Sarga from it is verified.
                final editions = (report['provenance']?['editions'] as List?)?.join(', ') ?? '';
                final editionLine = verified == 0
                    ? (editions.isEmpty
                        ? 'Edition: none verified yet'
                        : 'Edition: $editions (registered, not yet verified)')
                    : 'Edition: $editions';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sargas Imported: $imported / $expected',
                      style: const TextStyle(color: AppTheme.softCreamText, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Human-verified: $verified / $expected',
                      style: const TextStyle(color: AppTheme.softCreamText, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      editionLine,
                      style: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (imported / expected).clamp(0.0, 1.0),
                        backgroundColor: Colors.white10,
                        color: AppTheme.saffronPrimary,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Translation Coverage: $pct%',
                      style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.saffronPrimary)),
              error: (_, __) => const Text('Failed to load coverage report.', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader('SUPPORT THE PROJECT'),
          Container(
            decoration: AppTheme.devotionalCardDecoration(),
            child: ListTile(
              leading: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
              title: const Text('Donate & Support Seva', style: TextStyle(color: AppTheme.softCreamText)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DonationScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader(l10n.settingsAbout),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.devotionalCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsAboutBody,
                  style: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsVersion('1.0.0'),
                  style: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader('LEGAL & TRUST INFO'),
          Container(
            decoration: AppTheme.devotionalCardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.goldAccent),
                  title: const Text('AI Disclaimer', style: TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () => _showInfoDialog(
                    context, 
                    'AI Disclaimer', 
                    'SitaRam AI Guide is an educational study assistant. AI-generated responses are derived from RAG contexts and are for learning and reference only. They do not constitute official religious authority, scriptural rulings, or divine instructions. Please cross-reference responses with traditional commentaries.'
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.copyright_rounded, color: AppTheme.goldAccent),
                  title: const Text('Source & Copyright Info', style: TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () => _showInfoDialog(
                    context, 
                    'Source & Copyright', 
                    'The Manmatha Nath Dutt translation of the Valmiki Ramayana (1891, public domain) is the registered source edition for this project, but no Sarga from it has been ingested or verified yet. The chapters currently in the app are editorial retellings of unverified provenance, shown with their review status. They are not attributed to any translator and are excluded from AI retrieval until a human reviewer verifies them against the source edition. See Corpus Coverage Status above for exact verified counts.'
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.translate_rounded, color: AppTheme.goldAccent),
                  title: const Text('Translation Disclaimer', style: TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () => _showInfoDialog(
                    context, 
                    'Translation Disclaimer', 
                    'Scriptural translations may vary across different traditions and editions. The translations provided inside the SitaRam application (English, Bengali, Spanish) are intended for study assistance and do not represent the only authoritative readings.'
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.goldAccent),
                  title: Text(l10n.settingsPrivacyPolicy, style: const TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () => _showInfoDialog(
                    context, 
                    'Privacy Policy', 
                    'SitaRam respects your privacy. All reflection notes, bookmark details, and study stats are stored locally on your device. We do not track or sell your reading habits.'
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppTheme.goldAccent),
                  title: Text(l10n.settingsTerms, style: const TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () => _showInfoDialog(
                    context, 
                    'Terms of Service', 
                    'By using SitaRam, you agree to use the educational resources for personal, devotional, and study purposes only. Content scraping or abuse of RAG servers is prohibited.'
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              '🪷 Jai Shri Ram 🪷',
              style: TextStyle(color: AppTheme.textDimMaroon, fontSize: 13),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    if (text.isEmpty) return const SizedBox(height: 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.goldAccent,
        ),
      ),
    );
  }
}

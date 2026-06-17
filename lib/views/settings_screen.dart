import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

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

          Container(
            decoration: AppTheme.devotionalCardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.goldAccent),
                  title: Text(l10n.settingsPrivacyPolicy, style: const TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppTheme.goldAccent),
                  title: Text(l10n.settingsTerms, style: const TextStyle(color: AppTheme.softCreamText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textDimMaroon),
                  onTap: () {},
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

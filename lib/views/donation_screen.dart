import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> with SingleTickerProviderStateMixin {
  late TabController _billingTabController;

  final List<Map<String, String>> _oneTimeTiers = [
    {"amount": "\$1.00", "title": "Blessing", "desc": "Assists with basic server hosting costs."},
    {"amount": "\$5.00", "title": "Supporter", "desc": "Funds native translation reviews for 10 pages."},
    {"amount": "\$11.00", "title": "Devotional Support", "desc": "Funds full chapter OCR correction audits.", "highlight": "true"},
    {"amount": "\$21.00", "title": "Community Support", "desc": "Assists in editing Bangla & Spanish summaries."},
    {"amount": "\$51.00", "title": "Lifetime Gratitude", "desc": "Sponsors voice recordings for audiobook narrations."},
  ];

  final List<Map<String, String>> _monthlyTiers = [
    {"amount": "\$3.00/mo", "title": "Sustainer", "desc": "Helps ensure database performance monthly."},
    {"amount": "\$7.00/mo", "title": "Dharma Patron", "desc": "Supports continuous AI compute credits.", "highlight": "true"},
    {"amount": "\$11.00/mo", "title": "Guru Sewak", "desc": "Sponsors ongoing multilingual content work."},
  ];

  @override
  void initState() {
    super.initState();
    _billingTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _billingTabController.dispose();
    super.dispose();
  }

  Future<void> _processPurchase(String tierTitle, String amount, AppLocalizations l10n) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBgMaroon,
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppTheme.goldAccent),
            const SizedBox(width: 10),
            Flexible(
              child: Text(l10n.donateSimulatedTitle,
                  style: const TextStyle(color: AppTheme.softCreamText, fontSize: 18)),
            ),
          ],
        ),
        content: Text(
          l10n.donateSimulatedBody(amount, tierTitle),
          style: const TextStyle(color: AppTheme.softCreamText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.donateDhanyavad, style: const TextStyle(color: AppTheme.goldAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.maroonBg, Color(0xFF381207)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  title: Text(l10n.donateTitle),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 10),

                      // Hero Banner
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: AppTheme.lotusCardDecoration(),
                          child: Column(
                            children: [
                              const Icon(Icons.volunteer_activism_rounded,
                                  size: 48, color: AppTheme.goldAccent),
                              const SizedBox(height: 16),
                              Text(
                                l10n.donateHeading,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppTheme.softCreamText,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.donateBody,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textDimMaroon,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildRuleRow(Icons.done_all_rounded, l10n.donateNoSubscription),
                      _buildRuleRow(Icons.lock_open_rounded, l10n.donateNoPay),
                      _buildRuleRow(Icons.block_rounded, l10n.donateNoAds),

                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.templeObsidian,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _billingTabController,
                          indicatorColor: AppTheme.saffronPrimary,
                          labelColor: AppTheme.saffronPrimary,
                          unselectedLabelColor: AppTheme.textDimMaroon,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: [
                            Tab(text: l10n.donateOneTime),
                            Tab(text: l10n.donateMonthly),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 380,
                        child: TabBarView(
                          controller: _billingTabController,
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _oneTimeTiers.length,
                              itemBuilder: (context, idx) =>
                                  _buildTierCard(_oneTimeTiers[idx], l10n),
                            ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _monthlyTiers.length,
                              itemBuilder: (context, idx) =>
                                  _buildTierCard(_monthlyTiers[idx], l10n),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          l10n.donateFooter,
                          style: TextStyle(
                              color: AppTheme.textDimMaroon,
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.goldAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.softCreamText))),
        ],
      ),
    );
  }

  Widget _buildTierCard(Map<String, String> tier, AppLocalizations l10n) {
    final bool highlighted = tier["highlight"] == "true";
    final amount = tier["amount"]!;
    final title = tier["title"]!;
    final desc = tier["desc"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.saffronPrimary.withValues(alpha: 0.08)
            : AppTheme.cardBgMaroon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? AppTheme.goldAccent : Colors.white10,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: highlighted ? AppTheme.goldAccent : AppTheme.softCreamText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.textDimMaroon)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: highlighted ? AppTheme.saffronPrimary : Colors.white12,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => _processPurchase(title, amount, l10n),
            child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

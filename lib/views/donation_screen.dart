import 'package:flutter/material.dart';
import '../theme.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> with SingleTickerProviderStateMixin {
  late TabController _billingTabController;

  // Tiers data
  final List<Map<String, String>> _oneTimeTiers = [
    {"amount": "\$1.00", "title": "Blessing", "desc": "Assists with basic server hosting costs."},
    {"amount": "\$5.00", "title": "Supporter", "desc": "Funds native translation reviews for 10 pages."},
    {"amount": "\$11.00", "title": "Devotional Support", "desc": "Funds full chapter OCR correction audits.", "highlight": "true"},
    {"amount": "\$21.00", "title": "Community Support", "desc": "Assists in editing Bangla study summaries."},
    {"amount": "\$51.00", "title": "Lifetime Gratitude", "desc": "Sponsors voice recordings for audiobook narrations."},
  ];

  final List<Map<String, String>> _monthlyTiers = [
    {"amount": "\$3.00/mo", "title": "Sustainer", "desc": "Helps ensure database performance monthly."},
    {"amount": "\$7.00/mo", "title": "Dharma Patron", "desc": "Supports continuous OCR ingestion workflow.", "highlight": "true"},
    {"amount": "\$11.00/mo", "title": "Guru Sewak", "desc": "Sponsors continuous AI compute API credits."},
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

  // Future Apple In-App Purchase & Google Play Billing Integration Stub (Priority 7)
  Future<void> _processPurchase(String tierTitle, String amount) async {
    /*
      TODO: Integrate official billing plugins (e.g. in_app_purchase package)
      
      1. Initialize purchase connection:
         final InAppPurchase _iap = InAppPurchase.instance;
         final bool available = await _iap.isAvailable();
      
      2. Query product details matching product IDs (e.g. 'com.leadai.sitaram.support_1'):
         Set<String> _kIds = {'com.leadai.sitaram.support_1', ...};
         final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      
      3. Launch billing flow:
         final PurchaseParam purchaseParam = PurchaseParam(productDetails: response.productDetails[index]);
         _iap.buyConsumable(purchaseParam: purchaseParam);
         
      4. Listen to purchase status streams and verify receipts on backend.
    */
    
    // For MVP, we simulate a successful transaction
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBgMaroon,
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppTheme.goldAccent),
            SizedBox(width: 10),
            Text('Support Successful', style: TextStyle(color: AppTheme.softCreamText, fontSize: 18)),
          ],
        ),
        content: Text(
          'Thank you! Your simulated contribution of $amount for "$tierTitle" was successful. In-App Purchase billing will be connected prior to app store deployment.',
          style: const TextStyle(color: AppTheme.softCreamText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dhanyavad', style: TextStyle(color: AppTheme.goldAccent)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      body: Stack(
        children: [
          // Devotional Background
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
                  title: const Text('Support & Seva'),
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
                              const Icon(
                                Icons.volunteer_activism_rounded,
                                size: 48,
                                color: AppTheme.goldAccent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sitaram is Free & Pure',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.softCreamText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              
                              // Exact requested copy (Priority 7)
                              Text(
                                'SITARAM is free for everyone. Your donation helps us maintain the app, improve audiobook quality, add Bangla and English learning resources, support AI explanations, and share the wisdom of the Ramayana with more people.',
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

                      // Principles checkmark grid (Priority 7)
                      _buildRuleRow(Icons.done_all_rounded, 'No Subscriptions Required'),
                      _buildRuleRow(Icons.lock_open_rounded, 'Zero Locked Content / Paywalls'),
                      _buildRuleRow(Icons.block_rounded, 'No Ads or Interruptions'),
                      
                      const SizedBox(height: 24),
                      
                      // Tab Bar to switch One-Time vs Monthly (Priority 7)
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
                          tabs: const [
                            Tab(text: 'One-Time Blessing'),
                            Tab(text: 'Monthly Seva'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tab View List Content
                      SizedBox(
                        height: 380,
                        child: TabBarView(
                          controller: _billingTabController,
                          children: [
                            // One-time list
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _oneTimeTiers.length,
                              itemBuilder: (context, idx) {
                                final tier = _oneTimeTiers[idx];
                                return _buildTierCard(tier);
                              },
                            ),

                            // Monthly list
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _monthlyTiers.length,
                              itemBuilder: (context, idx) {
                                final tier = _monthlyTiers[idx];
                                return _buildTierCard(tier);
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'May dharma guide all your actions.',
                          style: TextStyle(
                            color: AppTheme.textDimMaroon,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
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
          Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.softCreamText)),
        ],
      ),
    );
  }

  Widget _buildTierCard(Map<String, String> tier) {
    final bool highlighted = tier["highlight"] == "true";
    final amount = tier["amount"]!;
    final title = tier["title"]!;
    final desc = tier["desc"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: highlighted ? AppTheme.saffronPrimary.withOpacity(0.08) : AppTheme.cardBgMaroon,
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
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textDimMaroon),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: highlighted ? AppTheme.saffronPrimary : Colors.white12,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => _processPurchase(title, amount),
            child: Text(
              amount,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

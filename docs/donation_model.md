# SitaRam Devotional Support & Donation Model

This document outlines the design principles of the SitaRam donation model and the future integration paths for mobile app billing.

---

## 1. Monetization Principles (Dharma first)

The SitaRam app is built as a service (seva) to share the Ramayana. It adheres to 5 strict rules:
- **No Paywalls**: Every verse, chapter, translation, and audiobook is 100% accessible.
- **No Subscription Locks**: Users do not need a subscription to access features.
- **No Interruptive Popups**: The app will never display aggressive popups begging for donations.
- **No Ads**: The reading experience is kept clean and quiet.
- **Optional Support**: Donations are entirely voluntary and are presented as support for server computing, translation, and recording costs.

---

## 2. Donation Structure

### A. One-Time Blessings
- **\$1.00 - Blessing**: Basic server hosting costs.
- **\$5.00 - Supporter**: Review support for 10 pages of translation.
- **\$11.00 - Devotional Support**: Funding chapter-level OCR audits.
- **\$21.00 - Community Support**: Funding Bangla studies.
- **\$51.00 - Lifetime Gratitude**: Sponsors professional voice actors for the audiobooks.

### B. Monthly Seva
- **\$3.00/month - Sustainer**
- **\$7.00/month - Dharma Patron**
- **\$11.00/month - Guru Sewak**

---

## 3. Future App Billing Integration Plan

We implement placeholder button callbacks in `lib/views/donation_screen.dart`. Prior to releasing the app on the stores:

### A. Dependency Configuration
Add the [in_app_purchase](https://pub.dev/packages/in_app_purchase) package to `pubspec.yaml`:
```yaml
dependencies:
  in_app_purchase: ^3.1.5
```

### B. Store Setup
1. **Google Play Console**: Under **Monetize > Products**, create In-App Products (for one-time tiers) and Subscriptions (for monthly tiers) matching the IDs:
   - `com.leadai.sitaram.blessing_1`
   - `com.leadai.sitaram.sevasub_3`
2. **App Store Connect**: Under **Features > In-App Purchases**, configure matching Consumable/Non-Consumable items and Auto-Renewable Subscriptions.

### C. Implementation Steps
1. Listen to the purchase stream inside the app's initialization:
   ```dart
   final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
   purchaseUpdated.listen((purchaseDetailsList) {
     _handlePurchaseUpdates(purchaseDetailsList);
   });
   ```
2. Query products and trigger the purchase flow when a tier card is tapped:
   ```dart
   final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(productIds);
   final PurchaseParam purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
   InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
   ```
3. Complete the purchase state transition and update local settings to show a custom thank you badge.

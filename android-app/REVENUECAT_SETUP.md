# RevenueCat Integration Guide

## Overview
Jeffrey Pocket Lawyer now includes full RevenueCat integration for subscription management with Pro features.

## ✅ Completed Implementation

### 1. Dependencies Added
- `purchases_flutter: ^8.0.0` - Core RevenueCat SDK
- `purchases_ui_flutter: ^8.0.0` - Paywall and Customer Center UI

### 2. Files Created
- `lib/core/revenuecat_service.dart` - Main RevenueCat service
- `lib/presentation/subscription_screen.dart` - Subscription management UI

### 3. Files Modified
- `pubspec.yaml` - Added RevenueCat dependencies
- `lib/main.dart` - RevenueCat initialization
- `lib/presentation/providers.dart` - Subscription state providers
- `lib/presentation/settings_screen.dart` - Subscription status card
- `lib/core/revenuecat_service.dart` - Mixpanel tracking integration

### 4. Features Implemented
- ✅ Entitlement checking for "Jeffrey_Pocket_Lawyer Pro"
- ✅ Paywall display with RevenueCat Paywall
- ✅ Customer Center integration
- ✅ Purchase management (yearly, monthly, weekly)
- ✅ Restore purchases functionality
- ✅ Subscription status tracking
- ✅ Mixpanel event tracking for all subscription events

## 🔧 RevenueCat Dashboard Setup Required

### Step 1: Create Project
1. Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Create a new project: "Jeffrey Pocket Lawyer"
3. Copy your API key (already added to `.env`)

### Step 2: Configure Entitlements
1. Navigate to **Products** → **Entitlements**
2. Create entitlement:
   - **Entitlement ID**: `Jeffrey_Pocket_Lawyer Pro`
   - **Display Name**: `Jeffrey Pocket Lawyer Pro`
   - **Description**: `Full access to all Pro features`

### Step 3: Create Products
Create products for each subscription tier:

#### iOS Products (App Store Connect)
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to your app → **Subscriptions**
3. Create these subscription groups:

**Monthly Subscription**
- Product ID: `com.example.android_app.monthly`
- Name: `Monthly Pro`
- Price: $9.99/month

**Yearly Subscription**
- Product ID: `com.example.android_app.yearly`
- Name: `Yearly Pro`
- Price: $79.99/year

**Weekly Subscription**
- Product ID: `com.example.android_app.weekly`
- Name: `Weekly Pro`
- Price: $2.99/week

#### Android Products (Google Play Console)
1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to your app → **Monetize** → **Subscriptions**
3. Create the same products with identical Product IDs

### Step 4: Add Products to RevenueCat
1. In RevenueCat Dashboard, go to **Products**
2. Add products with matching Product IDs:
   - `com.example.android_app.yearly`
   - `com.example.android_app.monthly`
   - `com.example.android_app.weekly`

### Step 5: Create Offering
1. Navigate to **Products** → **Offerings**
2. Create offering:
   - **Offering ID**: `default`
   - **Display Name**: `Default Offering`

3. Add packages to offering:
   - **Monthly**: `$9.99/month`
   - **Yearly**: `$79.99/year` (Recommended)
   - **Weekly**: `$2.99/week`

### Step 6: Configure Paywall
1. Navigate to **Paywalls** in RevenueCat
2. Create paywall or use default paywall
3. Customize:
   - Title: "Upgrade to Jeffrey Pocket Lawyer Pro"
   - Features:
     - Unlimited AI queries
     - Advanced legal analysis
     - Document review
     - Priority support
   - Colors: Match your app theme (gradient: #5D5CDE to #7878F2)

### Step 7: Enable Customer Center
1. Navigate to **Customer Center** in RevenueCat
2. Enable Customer Center for your app
3. Customize appearance to match your app

## 🚀 Running the App

### Install Dependencies
```bash
cd android-app
flutter pub get
```

### Initialize Services
The app automatically initializes RevenueCat on startup:
- Loads API key from `.env`
- Configures RevenueCat SDK
- Sets up Mixpanel tracking

### Test in Development

#### Test Mode
1. Enable sandbox testing in RevenueCat
2. Use test accounts from Apple/Google Play
3. Verify purchase flows work correctly

#### Test Entitlements
```dart
// Check if user has Pro access
final hasPro = await RevenueCatService.hasProAccess();
print('Has Pro access: $hasPro');
```

#### Test Paywall
```dart
// Show paywall
await RevenueCatService.showPaywall(
  onDismissed: () {
    print('Paywall dismissed');
  },
);
```

#### Test Customer Center
```dart
// Show customer center
await RevenueCatService.showCustomerCenter();
```

## 📊 Mixpanel Events Tracked

All subscription events are automatically tracked in Mixpanel:

1. **RevenueCat Initialized** - SDK setup complete
2. **Purchase Attempted** - User started purchase flow
3. **Subscription Purchased** - Successful purchase
4. **Purchase Failed** - Purchase error
5. **Paywall Displayed** - Paywall shown to user
6. **Paywall Result** - Paywall interaction result
7. **Paywall Error** - Paywall display error
8. **Restore Purchases Attempted** - Restore flow started
9. **Purchases Restored** - Successful restore
10. **Restore Failed** - Restore error
11. **Customer Center Opened** - Customer center shown
12. **Customer Center Error** - Customer center error

## 🔒 Security Notes

1. **Never commit real API keys** - Use `.env` file (already in `.gitignore`)
2. **Test thoroughly** - Use sandbox accounts before production
3. **Validate receipts** - RevenueCat handles this automatically
4. **Monitor revenue** - Check RevenueCat dashboard regularly

## 📱 App Store Submission

### Before submitting to App Store/Google Play:

1. **Test all subscription flows**
   - Purchase
   - Restore
   - Cancel
   - Upgrade/downgrade

2. **Configure subscription groups**
   - Create subscription group in App Store Connect
   - Add all subscription products

3. **Review compliance**
   - Ensure clear pricing disclosure
   - Provide restore purchases button
   - Include subscription terms

4. **Test on real devices**
   - iOS sandbox account
   - Android test track

## 🛠️ Troubleshooting

### Common Issues

**Issue**: Products not appearing
- **Solution**: Ensure Product IDs match exactly in RevenueCat and App Store/Google Play

**Issue**: Entitlement not active
- **Solution**: Check that product is linked to correct entitlement in RevenueCat

**Issue**: Paywall not showing
- **Solution**: Verify offering is set as "current" in RevenueCat

**Issue**: Test purchases failing
- **Solution**: Use sandbox accounts, not real Apple ID/Google account

### Debug Mode
RevenueCat is set to verbose logging. Check console for:
- SDK initialization
- Product fetching
- Purchase flows
- Entitlement verification

## 📞 Support

- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **Flutter SDK**: https://www.revenuecat.com/docs/getting-started/installation/flutter
- **Paywalls**: https://www.revenuecat.com/docs/tools/paywalls
- **Customer Center**: https://www.revenuecat.com/docs/tools/customer-center

## 🎯 Next Steps

1. ✅ Complete RevenueCat dashboard setup
2. ✅ Create products in App Store Connect/Google Play Console
3. ✅ Test subscription flows in sandbox
4. ✅ Customize paywall design
5. ✅ Implement Pro feature gates in your app
6. ✅ Test with beta users
7. ✅ Submit to app stores

## 💡 Pro Feature Implementation Ideas

Once users subscribe, you can:
- Remove query limits
- Add advanced legal analysis
- Enable document upload/review
- Provide priority support
- Offer exclusive content
- Enable offline mode

The `hasProAccessProvider` is available throughout your app to check subscription status.

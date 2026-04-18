import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'mixpanel_service.dart';

/// Service for managing RevenueCat subscriptions and purchases
class RevenueCatService {
  static const String _entitlementID = 'Jeffrey_Pocket_Lawyer Pro';
  static bool _isInitialized = false;

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = dotenv.env['REVENUECAT_API_KEY'] ?? 'YOUR_REVENUECAT_KEY';

      // Configure Purchases with PurchasesConfiguration
      await Purchases.configure(PurchasesConfiguration(apiKey));

      _isInitialized = true;

      // Track installation
      MixpanelService.instance.track('RevenueCat Initialized');
    } catch (e) {
      throw Exception('Failed to initialize RevenueCat: $e');
    }
  }

  /// Get customer info
  static Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      throw Exception('Failed to get customer info: $e');
    }
  }

  /// Check if user has Pro entitlement
  static Future<bool> hasProAccess() async {
    try {
      final customerInfo = await getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get offering for paywall
  static Future<Offering?> getCurrentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      return null;
    }
  }

  /// Purchase package - returns PurchaseResult
  static Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      // Track purchase attempt
      MixpanelService.track('Purchase Attempted', {
        'package_identifier': package.identifier,
      });

      PurchaseResult result;
      if (Platform.isIOS) {
        result = await Purchases.purchasePackage(package);
      } else {
        result = await Purchases.purchasePackage(
          package,
          googleProductChangeInfo: null,
        );
      }

      // Track successful purchase
      MixpanelService.track('Subscription Purchased', {
        'package_identifier': package.identifier,
      });

      return result;
    } catch (e) {
      // Track purchase error
      MixpanelService.track('Purchase Failed', {
        'error': e.toString(),
        'package_identifier': package.identifier,
      });
      throw Exception('Purchase failed: $e');
    }
  }

  /// Show paywall
  static Future<void> showPaywall({required VoidCallback onDismissed}) async {
    try {
      // Track paywall view
      MixpanelService.track('Paywall Displayed');

      final paywallResult = await RevenueCatUI.presentPaywall();

      // Track paywall result
      MixpanelService.track('Paywall Result', {
        'result': paywallResult.toString(),
      });

      if (paywallResult == PaywallResult.purchased ||
          paywallResult == PaywallResult.restored) {
        // Track successful purchase/restore
        MixpanelService.track('Subscription Purchased', {
          'result': paywallResult.toString(),
        });
      }
      onDismissed();
    } catch (e) {
      // Track paywall error
      MixpanelService.track('Paywall Error', {
        'error': e.toString(),
      });
      onDismissed();
    }
  }

  /// Restore purchases
  static Future<CustomerInfo> restorePurchases() async {
    try {
      MixpanelService.track('Restore Purchases Attempted');
      final result = await Purchases.restorePurchases();

      // Track successful restore
      MixpanelService.track('Purchases Restored', {
        'success': true,
      });

      return result;
    } catch (e) {
      // Track restore failure
      MixpanelService.track('Restore Failed', {
        'error': e.toString(),
      });
      throw Exception('Restore failed: $e');
    }
  }

  /// Get subscription status
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final customerInfo = await getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementID];

      if (entitlement == null) {
        return {
          'isActive': false,
          'willRenew': false,
          'periodType': 'none',
        };
      }

      return {
        'isActive': entitlement.isActive,
        'willRenew': entitlement.willRenew,
        'periodType': entitlement.periodType.toString(),
        'latestExpirationDate': entitlement.expirationDate,
      };
    } catch (e) {
      return {
        'isActive': false,
        'willRenew': false,
        'periodType': 'error',
      };
    }
  }

  /// Show customer center
  static Future<void> showCustomerCenter() async {
    try {
      MixpanelService.track('Customer Center Opened');
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      MixpanelService.track('Customer Center Error', {
        'error': e.toString(),
      });
      throw Exception('Failed to show customer center: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';

import '../core/revenuecat_service.dart';
import 'providers.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final hasProAccessAsync = ref.watch(hasProAccessProvider);
    final subscriptionStatusAsync = ref.watch(subscriptionStatusProvider);
    final currentOfferingAsync = ref.watch(currentOfferingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeffrey Pocket Lawyer Pro'),
        actions: [
          // Customer Center button
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: _showCustomerCenter,
            tooltip: 'Manage Subscription',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasProAccessAsync.value ?? false
                              ? Icons.workspace_premium
                              : Icons.lock,
                          color: hasProAccessAsync.value ?? false
                              ? Colors.amber
                              : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasProAccessAsync.value ?? false
                                    ? 'Pro Active'
                                    : 'Free Plan',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                hasProAccessAsync.value ?? false
                                    ? 'You have full access to all features'
                                    : 'Upgrade for unlimited legal assistance',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Features List
            const Text(
              'Pro Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.all_inclusive, 'Unlimited AI queries'),
            _buildFeatureItem(Icons.gavel, 'Advanced legal analysis'),
            _buildFeatureItem(Icons.description, 'Document review'),
            _buildFeatureItem(Icons.support_agent, 'Priority support'),

            const SizedBox(height: 24),

            // Upgrade Button
            if (!(hasProAccessAsync.value ?? false))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _showPaywall,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Upgrade to Pro',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _showCustomerCenter,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Manage Subscription'),
                ),
              ),

            const SizedBox(height: 16),

            // Restore Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : _restorePurchases,
                child: const Text('Restore Purchases'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaywall() async {
    setState(() => _isLoading = true);
    try {
      await RevenueCatService.showPaywall(
        onDismissed: () {
          setState(() => _isLoading = false);
          ref.invalidate(hasProAccessProvider);
          ref.invalidate(subscriptionStatusProvider);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCustomerCenter() async {
    setState(() => _isLoading = true);
    try {
      await RevenueCatService.showCustomerCenter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      ref.invalidate(hasProAccessProvider);
      ref.invalidate(subscriptionStatusProvider);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    try {
      await RevenueCatService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      ref.invalidate(hasProAccessProvider);
      ref.invalidate(subscriptionStatusProvider);
    }
  }
}

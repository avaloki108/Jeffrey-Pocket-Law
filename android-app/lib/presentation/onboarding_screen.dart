import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _countyController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final county = ref.read(selectedCountyProvider);
      if (county.isNotEmpty) {
        _countyController.text = county;
      }
    });
  }

  @override
  void dispose() {
    _countyController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({required bool goToAuth}) async {
    setState(() => _isSaving = true);
    final storage = ref.read(secureStorageProvider);
    final selectedState = ref.read(selectedStateProvider);
    final selectedJurisdiction = ref.read(selectedJurisdictionProvider);
    final selectedCounty = _countyController.text.trim();
    final selectedPlan = ref.read(selectedPlanProvider);

    ref.read(selectedCountyProvider.notifier).state = selectedCounty;

    await storage.put('onboarding_complete', 'true');
    await storage.put('selected_state', selectedState);
    await storage.put('selected_jurisdiction', selectedJurisdiction);
    await storage.put('selected_county', selectedCounty);
    await storage.put('selected_plan', selectedPlan);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(goToAuth ? '/auth' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final selectedStateAbbr = ref.watch(selectedStateProvider);
    final selectedStateName = abbrToStateName[selectedStateAbbr] ?? 'Colorado';
    final selectedJurisdiction = ref.watch(selectedJurisdictionProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Jeffrey'),
        backgroundColor: const Color(0xFF5D5CDE),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Legal help in everyday language.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Set your location and plan once, then start asking questions right away.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: 1,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF5D5CDE)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _SetupBadge(
                      icon: Icons.place_outlined, label: 'Pick your state'),
                  _SetupBadge(
                      icon: Icons.balance_outlined,
                      label: 'Choose legal scope'),
                  _SetupBadge(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Select a plan'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Choose your state'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedStateName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: stateNameToAbbr.keys
                    .map((name) =>
                        DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedStateProvider.notifier).state =
                        stateNameToAbbr[value] ?? 'CO';
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('County optional'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countyController,
                decoration: const InputDecoration(
                  hintText: 'Denver',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => ref
                    .read(selectedCountyProvider.notifier)
                    .state = value.trim(),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'County', label: Text('County')),
                  ButtonSegment(value: 'State', label: Text('State')),
                  ButtonSegment(value: 'Federal', label: Text('Federal')),
                ],
                selected: {selectedJurisdiction},
                onSelectionChanged: (selection) {
                  ref.read(selectedJurisdictionProvider.notifier).state =
                      selection.first;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Choose your plan'),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'Free with ads',
                subtitle:
                    'Ask questions, translate legal jargon, basic conversation history.',
                value: 'Free',
                selectedValue: selectedPlan,
                accent: Colors.orange,
                onTap: () =>
                    ref.read(selectedPlanProvider.notifier).state = 'Free',
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'Plus',
                subtitle:
                    'No ads, longer saved history, deeper source summaries.',
                value: 'Plus',
                selectedValue: selectedPlan,
                accent: Colors.blue,
                onTap: () =>
                    ref.read(selectedPlanProvider.notifier).state = 'Plus',
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'Pro',
                subtitle:
                    'Best for serious research, multi-jurisdiction work, premium explainers.',
                value: 'Pro',
                selectedValue: selectedPlan,
                accent: Colors.green,
                onTap: () =>
                    ref.read(selectedPlanProvider.notifier).state = 'Pro',
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D5CDE).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF5D5CDE).withOpacity(0.18)),
                ),
                child: Text(
                  selectedJurisdiction == 'County' &&
                          _countyController.text.trim().isNotEmpty
                      ? 'You will start with $selectedPlan access for ${_countyController.text.trim()} County, $selectedStateName.'
                      : 'You will start with $selectedPlan access for $selectedJurisdiction law in $selectedStateName.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'You can change all of this later in Settings.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _completeOnboarding(goToAuth: false),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: const Color(0xFF5D5CDE),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Start now as guest'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _completeOnboarding(goToAuth: true),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52)),
                  child: const Text('Continue to sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _SetupBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SetupBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF5D5CDE).withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5D5CDE).withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF5D5CDE)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String selectedValue;
  final Color accent;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? accent : Colors.grey.shade300,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

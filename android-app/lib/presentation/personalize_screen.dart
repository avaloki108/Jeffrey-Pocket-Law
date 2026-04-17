import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class PersonalizeScreen extends ConsumerStatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  ConsumerState<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends ConsumerState<PersonalizeScreen> {
  final _nameController = TextEditingController();
  final _lawyerNameController = TextEditingController(text: 'Jeffrey');
  String _ageRange = '25-34';
  final Set<String> _useCases = {};
  bool _isSaving = false;
  int _step = 0;

  final _useCaseOptions = {
    'housing': {
      'label': 'Housing & Rent',
      'icon': Icons.home_outlined,
      'desc': 'Landlord issues, leases, evictions'
    },
    'employment': {
      'label': 'Work & Employment',
      'icon': Icons.work_outline,
      'desc': 'Getting fired, wages, discrimination'
    },
    'family': {
      'label': 'Family & Custody',
      'icon': Icons.family_restroom,
      'desc': 'Divorce, custody, child support'
    },
    'criminal': {
      'label': 'Criminal & Traffic',
      'icon': Icons.gavel,
      'desc': 'Tickets, court dates, charges'
    },
    'money': {
      'label': 'Money & Debt',
      'icon': Icons.attach_money,
      'desc': 'Collections, bankruptcy, credit'
    },
    'business': {
      'label': 'Small Business',
      'icon': Icons.store_outlined,
      'desc': 'LLCs, contracts, liability'
    },
    'immigration': {
      'label': 'Immigration',
      'icon': Icons.public,
      'desc': 'Visas, status, DACA'
    },
    'consumer': {
      'label': 'Consumer Rights',
      'icon': Icons.shield_outlined,
      'desc': 'Scams, warranties, returns'
    },
  };

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final storage = ref.read(secureStorageProvider);

    final userName = _nameController.text.trim();
    final lawyerName = _lawyerNameController.text.trim().isEmpty
        ? 'Jeffrey'
        : _lawyerNameController.text.trim();

    await storage.put('user_name', userName);
    await storage.put('user_age_range', _ageRange);
    await storage.put('user_use_cases', _useCases.join(','));
    await storage.put('lawyer_name', lawyerName);
    await storage.put('personalized', 'true');

    // Update providers
    ref.read(userNameProvider.notifier).state = userName;
    ref.read(lawyerNameProvider.notifier).state = lawyerName;
    ref.read(userAgeRangeProvider.notifier).state = _ageRange;
    ref.read(userUseCasesProvider.notifier).state = _useCases.toList();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lawyerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: LinearProgressIndicator(
                value: (_step + 1) / 3,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: theme.dividerColor,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF5D5CDE)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStep(theme),
                ),
              ),
            ),
            // Navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_step < 2)
                    ElevatedButton(
                      onPressed:
                          _canAdvance() ? () => setState(() => _step++) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D5CDE),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                      ),
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D5CDE),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(160, 48),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Let\u2019s go'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canAdvance() {
    if (_step == 0) return _nameController.text.trim().isNotEmpty;
    if (_step == 1) return _useCases.isNotEmpty;
    return true;
  }

  Widget _buildStep(ThemeData theme) {
    switch (_step) {
      case 0:
        return _buildAboutYou(theme);
      case 1:
        return _buildUseCases(theme);
      case 2:
        return _buildCustomize(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAboutYou(ThemeData theme) {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hey \u2014 let\u2019s set things up.',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'I\u2019m going to customize how I talk to you so I\u2019m actually useful, not just generic.',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),
        const Text('What should I call you?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'First name or nickname'),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        const Text('How old are you? (roughly)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('This helps me know how to explain things.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Under 18', '18-24', '25-34', '35-44', '45-54', '55+']
              .map((range) => ChoiceChip(
                    label: Text(range),
                    selected: _ageRange == range,
                    onSelected: (_) => setState(() => _ageRange = range),
                    selectedColor: const Color(0xFF5D5CDE).withOpacity(0.15),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildUseCases(ThemeData theme) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you need help with, ${_nameController.text.trim()}?',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick all that apply. I\u2019ll focus on these areas first.',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ..._useCaseOptions.entries.map((entry) {
          final id = entry.key;
          final data = entry.value;
          final selected = _useCases.contains(id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() {
                if (selected) {
                  _useCases.remove(id);
                } else {
                  _useCases.add(id);
                }
              }),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5D5CDE).withOpacity(0.08)
                      : theme.cardTheme.color ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        selected ? const Color(0xFF5D5CDE) : theme.dividerColor,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(data['icon'] as IconData,
                        color:
                            selected ? const Color(0xFF5D5CDE) : Colors.grey),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['label'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(data['desc'] as String,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle,
                          color: Color(0xFF5D5CDE), size: 22),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomize(ThemeData theme) {
    final userName = _nameController.text.trim();
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'One last thing.',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'My name is Jeffrey by default \u2014 but if you\u2019d rather call me something else, go for it.',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        const Text('Your pocket lawyer\u2019s name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _lawyerNameController,
          decoration: const InputDecoration(hintText: 'Jeffrey'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF5D5CDE).withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: const Color(0xFF5D5CDE).withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Here\u2019s how I\u2019ll work for you:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _SummaryRow(
                  icon: Icons.person, text: 'I\u2019ll call you $userName'),
              _SummaryRow(
                  icon: Icons.badge_outlined,
                  text:
                      'My name is ${_lawyerNameController.text.trim().isEmpty ? "Jeffrey" : _lawyerNameController.text.trim()}'),
              _SummaryRow(
                  icon: Icons.cake_outlined,
                  text: 'Tuned for age range: $_ageRange'),
              _SummaryRow(
                  icon: Icons.topic_outlined,
                  text:
                      'Focused on: ${_useCases.map((u) => _useCaseOptions[u]?['label'] ?? u).join(', ')}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You can change all of this later in Settings.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5D5CDE)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

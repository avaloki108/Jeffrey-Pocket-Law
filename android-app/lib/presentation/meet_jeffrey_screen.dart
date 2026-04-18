import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class MeetJeffreyScreen extends ConsumerStatefulWidget {
  const MeetJeffreyScreen({super.key});

  @override
  ConsumerState<MeetJeffreyScreen> createState() => _MeetJeffreyScreenState();
}

class _MeetJeffreyScreenState extends ConsumerState<MeetJeffreyScreen> {
  int _selectedExample = 0;
  bool _isNavigating = false;

  final List<Map<String, dynamic>> _examples = const [
    {
      'question': 'Can my landlord keep my deposit?',
      'answer': 'Short answer: In Colorado, landlords have 30 days to return your deposit or give you a written list of deductions.',
      'topic': 'Housing',
    },
    {
      'question': 'What happens if I miss court?',
      'answer': 'Short answer: The judge may issue a bench warrant for your arrest, depending on the type of case.',
      'topic': 'Court',
    },
    {
      'question': 'Can my boss fire me for no reason?',
      'answer': 'Short answer: In most states, yes - employment is "at will" unless you have a contract.',
      'topic': 'Work',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-rotate examples
    _startExampleRotation();
  }

  Future<void> _startExampleRotation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _selectedExample = (_selectedExample + 1) % _examples.length;
        });
      }
    }
  }

  Future<void> _continueToOnboarding() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    // Mark that user has met Jeffrey
    final storage = ref.read(secureStorageProvider);
    await storage.put('met_jeffrey', 'true');

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/jeffrey_05.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Meet Jeffrey',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your friendly neighborhood pocket lawyer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // What Jeffrey does
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What Jeffrey can do:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCapability(
                        icon: Icons.search,
                        title: 'Explains the law',
                        description: 'In plain English, not legalese'),
                    const SizedBox(height: 12),
                    _buildCapability(
                        icon: Icons.location_on,
                        title: 'Knows your location',
                        description: 'State, county, and federal laws'),
                    const SizedBox(height: 12),
                    _buildCapability(
                        icon: Icons.menu_book,
                        title: 'Cites real sources',
                        description: 'Actual statutes and cases'),
                    const SizedBox(height: 12),
                    _buildCapability(
                        icon: Icons.shield_outlined,
                        title: 'Free to use',
                        description: 'No credit card required'),
                  ],
                ),
              ),
              // Sample Q&A
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'See how it works:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/jeffrey_05.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _examples[_selectedExample]['topic'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _examples[_selectedExample]['question'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _examples[_selectedExample]['answer'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _examples.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _selectedExample == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _selectedExample == index
                                ? const Color(0xFF5D5CDE)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNavigating
                      ? null
                      : () => _continueToOnboarding(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D5CDE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isNavigating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Let's set things up",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapability({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF5D5CDE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF5D5CDE)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

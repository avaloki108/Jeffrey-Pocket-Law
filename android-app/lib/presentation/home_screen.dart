import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/mixpanel_service.dart';
import 'chat_screen.dart';
import 'chat_state_notifier.dart';
import 'prompts_screen.dart';
import 'providers.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    PromptsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    final screenNames = ['Chat', 'Prompts', 'Settings'];
    MixpanelService.track('Page View', {
      'page_name': screenNames[index],
    });
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(promptSelectedProvider, (previous, next) {
      if (next != null && next.isNotEmpty && _selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      }
    });

    final selectedStateAbbr = ref.watch(selectedStateProvider);
    final selectedStateName = abbrToStateName[selectedStateAbbr] ?? 'Colorado';
    final selectedJurisdiction = ref.watch(selectedJurisdictionProvider);
    final selectedCounty = ref.watch(selectedCountyProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);

    final lawyerName = ref.watch(lawyerNameProvider);

    // Hide header on chat tab once there are messages
    final chatState = ref.watch(chatProvider);
    final hideHeader = _selectedIndex == 0 && chatState.messages.isNotEmpty;

    final scopeLabel = selectedJurisdiction == 'County' &&
            selectedCounty.isNotEmpty
        ? '$selectedPlan \u2022 $selectedCounty County, $selectedStateName'
        : '$selectedPlan \u2022 $selectedJurisdiction \u2022 $selectedStateName';

    return Scaffold(
      body: Column(
        children: [
          if (!hideHeader)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5D5CDE), Color(0xFF7878F2)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Text(
                      lawyerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        scopeLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // SafeArea top inset even when header hidden
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5D5CDE), Color(0xFF7878F2)],
                ),
              ),
              child: const SafeArea(
                bottom: false,
                child: SizedBox.shrink(),
              ),
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF5D5CDE),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Prompts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Config'),
        ],
      ),
    );
  }
}

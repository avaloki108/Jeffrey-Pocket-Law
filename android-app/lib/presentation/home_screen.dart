import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_screen.dart';
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

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    // Listen for prompt selection and switch to chat tab
    ref.listen<String?>(promptSelectedProvider, (previous, next) {
      if (next != null && next.isNotEmpty && _selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      }
    });

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                      Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // Reduced to 3 to match the number of items
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? const Color(0xFF5D5CDE)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

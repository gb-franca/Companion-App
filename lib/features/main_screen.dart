import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/preferences/preferences.dart';
import 'counter/counter_screen.dart';
import 'dice_roller/dice_roller_screen.dart';
import 'campaigns/campaigns_screen.dart';
import 'encyclopedia/encyclopedia_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CounterScreen(),
    DiceRollerScreen(),
    CampaignsScreen(),
    EncyclopediaScreen(),
  ];

  final List<String> _titles = const [
    'Contador de Recursos',
    'Rolador de Dados',
    'Campanhas e Mesas',
    'Enciclopédia Arcana',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    final appBar = AppBar(
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          tooltip: 'Alternar Tema',
        ),
      ],
    );

    if (isWide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) {
                setState(() {
                  _currentIndex = idx;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.shield_outlined),
                  selectedIcon: Icon(Icons.shield_rounded),
                  label: Text('Contador'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.casino_outlined),
                  selectedIcon: Icon(Icons.casino_rounded),
                  label: Text('Dados'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: Text('Campanhas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories_rounded),
                  label: Text('Enciclopédia'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Contador',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino_rounded),
            label: 'Dados',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Campanhas',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Enciclopédia',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/preferences/preferences.dart';
import 'dice_roller_provider.dart';

class DiceRollerScreen extends ConsumerStatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  ConsumerState<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends ConsumerState<DiceRollerScreen> {
  int _currentModifier = 0;
  final TextEditingController _modController = TextEditingController(text: '0');

  final List<Map<String, dynamic>> _diceTypes = [
    {'name': 'D4', 'type': 'd4', 'color': Colors.red},
    {'name': 'D6', 'type': 'd6', 'color': Colors.orange},
    {'name': 'D8', 'type': 'd8', 'color': Colors.green},
    {'name': 'D10', 'type': 'd10', 'color': Colors.teal},
    {'name': 'D12', 'type': 'd12', 'color': Colors.blue},
    {'name': 'D20', 'type': 'd20', 'color': Colors.indigo},
    {'name': 'D100', 'type': 'd100', 'color': Colors.purple},
  ];

  @override
  void dispose() {
    _modController.dispose();
    super.dispose();
  }

  void _updateModifier(int val) {
    setState(() {
      _currentModifier = val;
      _modController.text = val.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diceRollerProvider);
    final favorites = ref.watch(favoriteDiceProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    // Build the grid and controls
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Last Roll Display
        _LastRollDisplay(lastRoll: state.lastRoll),
        const SizedBox(height: 16),

        // Modifier Card
        _buildModifierCard(theme),
        const SizedBox(height: 16),

        // Favorites Row if any exist
        if (favorites.isNotEmpty) ...[
          Text(
            'Favoritos',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _diceTypes.where((d) => favorites.contains(d['type'])).map((d) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    avatar: Icon(Icons.casino_rounded, color: d['color'], size: 18),
                    label: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ref.read(diceRollerProvider.notifier).roll(d['type'], modifier: _currentModifier);
                    },
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // All Dice Grid
        Text(
          'Dados',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: _diceTypes.length,
          itemBuilder: (context, index) {
            final die = _diceTypes[index];
            final type = die['type'] as String;
            final isFav = favorites.contains(type);

            return Card(
              margin: EdgeInsets.zero,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isFav ? theme.colorScheme.secondary.withOpacity(0.5) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Roll Trigger area
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ref.read(diceRollerProvider.notifier).roll(type, modifier: _currentModifier);
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino_rounded, color: die['color'], size: 32),
                          const SizedBox(height: 4),
                          Text(
                            die['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite Star Button
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(favoriteDiceProvider.notifier).toggleFavorite(type);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          isFav ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFav ? theme.colorScheme.secondary : theme.hintColor.withOpacity(0.4),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );

    // Build the history panel
    final history = Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded),
                    const SizedBox(width: 8),
                    Text(
                      'Histórico',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (state.history.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(diceRollerProvider.notifier).clearHistory();
                    },
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Limpar'),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: state.history.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma rolagem nesta sessão.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.history.length,
                      itemBuilder: (context, idx) {
                        final roll = state.history[idx];
                        final timeStr =
                            "${roll.timestamp.hour.toString().padLeft(2, '0')}:${roll.timestamp.minute.toString().padLeft(2, '0')}:${roll.timestamp.second.toString().padLeft(2, '0')}";
                        
                        // Check for D20 special notifications in history too
                        final isD20 = roll.dieType.toLowerCase() == 'd20';
                        final isCrit = isD20 && roll.result == 20;
                        final isFumble = isD20 && roll.result == 1;

                        Color? textColor;
                        if (isCrit) textColor = Colors.amber[700];
                        if (isFumble) textColor = Colors.red[700];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            child: Text(
                              roll.dieType.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'Resultado: ',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${roll.total}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              if (isCrit) ...[
                                const SizedBox(width: 6),
                                const Text('🎯 CRÍTICO!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ],
                              if (isFumble) ...[
                                const SizedBox(width: 6),
                                const Text('💀 FUMBLE!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            'Dado: ${roll.result} | Mod: ${roll.modifier >= 0 ? "+${roll.modifier}" : roll.modifier}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Text(
                            timeStr,
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(child: controls),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: history,
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(child: controls),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: history,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildModifierCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Modificador de Rolagem',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Quick Modifiers buttons
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [-5, -2, 0, 2, 5].map((val) {
                      final isSelected = _currentModifier == val;
                      return ChoiceChip(
                        label: Text(val >= 0 ? '+$val' : '$val'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _updateModifier(val);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // Custom Mod Input
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _modController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setState(() {
                        _currentModifier = parsed;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LastRollDisplay extends StatelessWidget {
  final RollResult? lastRoll;

  const _LastRollDisplay({required this.lastRoll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (lastRoll == null) {
      return Card(
        elevation: 3,
        child: Container(
          height: 140,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.casino_rounded, size: 40, color: theme.hintColor.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(
                'Rolar um dado para começar!',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        ),
      );
    }

    final roll = lastRoll!;
    final isD20 = roll.dieType.toLowerCase() == 'd20';
    final isCrit = isD20 && roll.result == 20;
    final isFumble = isD20 && roll.result == 1;

    // Style elements based on success/fail
    Color resultColor = theme.colorScheme.primary;
    String statusText = 'Resultado';
    Gradient cardGradient = LinearGradient(
      colors: [
        theme.colorScheme.surfaceVariant,
        theme.colorScheme.surfaceVariant.withOpacity(0.7),
      ],
    );

    if (isCrit) {
      resultColor = Colors.amber[700]!;
      statusText = '💥 SUCESSO CRÍTICO!';
      cardGradient = const LinearGradient(
        colors: [
          Color(0xFF2E1C0A),
          Color(0xFF5A3E1B),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isFumble) {
      resultColor = Colors.red[700]!;
      statusText = '💀 FALHA CRÍTICA (FUMBLE)!';
      cardGradient = const LinearGradient(
        colors: [
          Color(0xFF2E0A0F),
          Color(0xFF5A1B24),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isCrit
              ? Colors.amber.withOpacity(0.5)
              : (isFumble ? Colors.red.withOpacity(0.5) : theme.colorScheme.primary.withOpacity(0.2)),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: cardGradient,
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              statusText.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: isCrit ? Colors.amber : (isFumble ? Colors.redAccent : theme.colorScheme.primary),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${roll.total}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCrit ? Colors.amber[300] : (isFumble ? Colors.red[300] : resultColor),
                    fontSize: 72,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Fórmula: [${roll.dieType.toUpperCase()}: ${roll.result}] ${roll.modifier >= 0 ? "+ ${roll.modifier}" : "- ${roll.modifier.abs()}"}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

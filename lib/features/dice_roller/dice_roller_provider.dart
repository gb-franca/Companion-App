import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RollResult {
  final String dieType;
  final int result;
  final int modifier;
  final int total;
  final List<int> individualRolls;
  final DateTime timestamp;

  RollResult({
    required this.dieType,
    required this.result,
    required this.modifier,
    required this.total,
    required this.individualRolls,
    required this.timestamp,
  });
}

class DiceRollerState {
  final RollResult? lastRoll;
  final List<RollResult> history;

  DiceRollerState({
    this.lastRoll,
    required this.history,
  });
}

class DiceRollerNotifier extends Notifier<DiceRollerState> {
  final Random _random = Random();

  @override
  DiceRollerState build() {
    return DiceRollerState(history: const []);
  }

  void roll(String dieNotation, {int modifier = 0}) {
    // Parse dice notation like "d20", "1d20", "2d6", "3d8", etc.
    final regExp = RegExp(r'^(\d*)d(\d+)$');
    final match = regExp.firstMatch(dieNotation.toLowerCase().trim());
    
    int diceCount = 1;
    int sides = 20;
    
    if (match != null) {
      final countStr = match.group(1);
      final sidesStr = match.group(2);
      if (countStr != null && countStr.isNotEmpty) {
        diceCount = int.parse(countStr);
      }
      if (sidesStr != null) {
        sides = int.parse(sidesStr);
      }
    } else {
      // Fallback parsing
      final clean = dieNotation.replaceAll(RegExp(r'\D'), '');
      sides = int.tryParse(clean) ?? 20;
    }
    
    int resultSum = 0;
    final List<int> rolls = [];
    for (int i = 0; i < diceCount; i++) {
      final r = _random.nextInt(sides) + 1;
      resultSum += r;
      rolls.add(r);
    }
    
    final int total = resultSum + modifier;

    final rollResult = RollResult(
      dieType: dieNotation,
      result: resultSum,
      modifier: modifier,
      total: total,
      individualRolls: rolls,
      timestamp: DateTime.now(),
    );

    state = DiceRollerState(
      lastRoll: rollResult,
      history: [rollResult, ...state.history],
    );
  }

  void clearHistory() {
    state = DiceRollerState(history: const []);
  }
}

final diceRollerProvider = NotifierProvider<DiceRollerNotifier, DiceRollerState>(() {
  return DiceRollerNotifier();
});

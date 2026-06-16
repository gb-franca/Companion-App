import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:companion_app/core/preferences/preferences.dart';
import 'package:companion_app/features/counter/counter_provider.dart';

void main() {
  group('CharacterNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'char_name': 'Thorin Oakenshield',
        'char_class': 'Guerreiro',
        'char_race': 'Anão',
        'char_hp': 12,
        'char_max_hp': 15,
        'char_mana': 4,
        'char_max_mana': 6,
        'char_level': 3,
        'char_str': 16,
        'char_dex': 10,
        'char_con': 14,
        'char_int': 8,
        'char_wis': 12,
        'char_cha': 10,
        'char_ac': 16,
      });

      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes state from SharedPreferences mock values', () {
      final state = container.read(counterProvider);
      
      expect(state.name, equals('Thorin Oakenshield'));
      expect(state.characterClass, equals('Guerreiro'));
      expect(state.characterRace, equals('Anão'));
      expect(state.hp, equals(12));
      expect(state.maxHp, equals(15));
      expect(state.mana, equals(4));
      expect(state.maxMana, equals(6));
      expect(state.level, equals(3));
      expect(state.strength, equals(16));
      expect(state.armorClass, equals(16));
    });

    test('Calculates ability modifiers correctly', () {
      final state = container.read(counterProvider);

      // FOR 16 -> +3
      expect(state.strengthModifier, equals(3));
      // DES 10 -> +0
      expect(state.dexterityModifier, equals(0));
      // CON 14 -> +2
      expect(state.constitutionModifier, equals(2));
      // INT 8 -> -1
      expect(state.intelligenceModifier, equals(-1));
      // SAB 12 -> +1
      expect(state.wisdomModifier, equals(1));
    });

    test('Calculates proficiency bonus and carrying capacity', () {
      final state = container.read(counterProvider);

      // Level 3 -> +2 prof bonus
      expect(state.proficiencyBonus, equals(2));
      // Carrying capacity: STR * 15 -> 16 * 15 = 240
      expect(state.carryingCapacity, equals(240.0));
    });

    test('Safety boundaries: HP cannot exceed maxHp and cannot go below 0', () {
      final notifier = container.read(counterProvider.notifier);

      // HP is 12, max HP is 15. Increment 4 times.
      notifier.incrementHp(); // 13
      notifier.incrementHp(); // 14
      notifier.incrementHp(); // 15
      notifier.incrementHp(); // Should stay 15
      
      expect(container.read(counterProvider).hp, equals(15));

      // Decrement below 0
      for (int i = 0; i < 20; i++) {
        notifier.decrementHp();
      }
      expect(container.read(counterProvider).hp, equals(0));
    });

    test('Safety boundaries: Mana cannot exceed maxMana and cannot go below 0', () {
      final notifier = container.read(counterProvider.notifier);

      // Mana is 4, max Mana is 6. Increment 3 times.
      notifier.incrementMana(); // 5
      notifier.incrementMana(); // 6
      notifier.incrementMana(); // Should stay 6
      
      expect(container.read(counterProvider).mana, equals(6));

      // Decrement below 0
      for (int i = 0; i < 10; i++) {
        notifier.decrementMana();
      }
      expect(container.read(counterProvider).mana, equals(0));
    });

    test('Long rest restores HP and Mana to their maximum values', () {
      final notifier = container.read(counterProvider.notifier);

      // Reduce HP and Mana
      notifier.decrementHp();
      notifier.decrementHp();
      notifier.decrementMana();
      notifier.decrementMana();

      expect(container.read(counterProvider).hp, equals(10));
      expect(container.read(counterProvider).mana, equals(2));

      // Rest
      notifier.longRest();

      expect(container.read(counterProvider).hp, equals(15));
      expect(container.read(counterProvider).mana, equals(6));
    });

    test('Toggling skill proficiencies updates state modifier', () {
      final notifier = container.read(counterProvider.notifier);
      final athletics = skillDefinitions.firstWhere((s) => s.id == 'athletics'); // Strength

      // Initially not proficient. Modifier is strengthModifier (+3)
      expect(container.read(counterProvider).getSkillModifier(athletics), equals(3));

      // Toggle proficiency (adds proficiency bonus: +3 + 2 = +5)
      notifier.toggleSkillProficiency('athletics');
      expect(container.read(counterProvider).getSkillModifier(athletics), equals(5));

      // Toggle again (removes proficiency bonus: back to +3)
      notifier.toggleSkillProficiency('athletics');
      expect(container.read(counterProvider).getSkillModifier(athletics), equals(3));
    });

    test('Managing inventory items works correctly', () {
      final notifier = container.read(counterProvider.notifier);

      final item = InventoryItem(
        id: '1',
        name: 'Corda de Escalada',
        quantity: 1,
        weight: 10.0,
        description: 'Corda resistente de 15 metros.',
      );

      // Add item
      notifier.addInventoryItem(item);
      expect(container.read(counterProvider).inventory.length, equals(1));
      expect(container.read(counterProvider).totalWeight, equals(10.0));

      // Update quantity
      notifier.updateInventoryItem(item.copyWith(quantity: 3));
      expect(container.read(counterProvider).inventory.first.quantity, equals(3));
      expect(container.read(counterProvider).totalWeight, equals(30.0));

      // Remove item
      notifier.removeInventoryItem('1');
      expect(container.read(counterProvider).inventory, isEmpty);
      expect(container.read(counterProvider).totalWeight, equals(0.0));
    });
  });
}

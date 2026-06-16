import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/preferences/preferences.dart';

class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final double weight;
  final String description;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.weight,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'weight': weight,
      'description': description,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
    );
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? weight,
    String? description,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      description: description ?? this.description,
    );
  }
}

class CharacterAttack {
  final String id;
  final String name;
  final int hitBonus;
  final String damageDice;
  final int damageBonus;
  final String notes;

  CharacterAttack({
    required this.id,
    required this.name,
    required this.hitBonus,
    required this.damageDice,
    required this.damageBonus,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hitBonus': hitBonus,
      'damageDice': damageDice,
      'damageBonus': damageBonus,
      'notes': notes,
    };
  }

  factory CharacterAttack.fromMap(Map<String, dynamic> map) {
    return CharacterAttack(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      hitBonus: map['hitBonus'] ?? 0,
      damageDice: map['damageDice'] ?? '1d6',
      damageBonus: map['damageBonus'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }

  CharacterAttack copyWith({
    String? id,
    String? name,
    int? hitBonus,
    String? damageDice,
    int? damageBonus,
    String? notes,
  }) {
    return CharacterAttack(
      id: id ?? this.id,
      name: name ?? this.name,
      hitBonus: hitBonus ?? this.hitBonus,
      damageDice: damageDice ?? this.damageDice,
      damageBonus: damageBonus ?? this.damageBonus,
      notes: notes ?? this.notes,
    );
  }
}

class SkillDefinition {
  final String id;
  final String name;
  final String attribute;

  const SkillDefinition({
    required this.id,
    required this.name,
    required this.attribute,
  });
}

const List<SkillDefinition> skillDefinitions = [
  SkillDefinition(id: 'acrobatics', name: 'Acrobacia', attribute: 'DES'),
  SkillDefinition(id: 'animal_handling', name: 'Adestrar Animais', attribute: 'SAB'),
  SkillDefinition(id: 'arcana', name: 'Arcanismo', attribute: 'INT'),
  SkillDefinition(id: 'athletics', name: 'Atletismo', attribute: 'FOR'),
  SkillDefinition(id: 'deception', name: 'Enganação', attribute: 'CAR'),
  SkillDefinition(id: 'history', name: 'História', attribute: 'INT'),
  SkillDefinition(id: 'insight', name: 'Intuição', attribute: 'SAB'),
  SkillDefinition(id: 'intimidation', name: 'Intimidação', attribute: 'CAR'),
  SkillDefinition(id: 'investigation', name: 'Investigação', attribute: 'INT'),
  SkillDefinition(id: 'medicine', name: 'Medicina', attribute: 'SAB'),
  SkillDefinition(id: 'nature', name: 'Natureza', attribute: 'INT'),
  SkillDefinition(id: 'perception', name: 'Percepção', attribute: 'SAB'),
  SkillDefinition(id: 'performance', name: 'Atuação', attribute: 'CAR'),
  SkillDefinition(id: 'persuasion', name: 'Persuasão', attribute: 'CAR'),
  SkillDefinition(id: 'religion', name: 'Religião', attribute: 'INT'),
  SkillDefinition(id: 'sleight_of_hand', name: 'Prestidigitação', attribute: 'DES'),
  SkillDefinition(id: 'stealth', name: 'Furtividade', attribute: 'DES'),
  SkillDefinition(id: 'survival', name: 'Sobrevivência', attribute: 'SAB'),
];

class CharacterState {
  final String name;
  final String characterClass;
  final String characterRace;
  final int hp;
  final int maxHp;
  final int mana;
  final int maxMana;
  final int level;
  
  // Core Attributes
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  
  // Armor Class (CA)
  final int armorClass;

  // Inventory & Wealth
  final List<InventoryItem> inventory;
  final int gold;
  final int silver;
  final int copper;

  // Attacks / Actions
  final List<CharacterAttack> attacks;

  // Skills Proficiency Set
  final Set<String> proficientSkills;

  CharacterState({
    required this.name,
    required this.characterClass,
    required this.characterRace,
    required this.hp,
    required this.maxHp,
    required this.mana,
    required this.maxMana,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.armorClass,
    required this.inventory,
    required this.gold,
    required this.silver,
    required this.copper,
    required this.attacks,
    required this.proficientSkills,
  });

  // Calculate D&D 5e style modifier
  static int getModifier(int value) {
    return ((value - 10) / 2).floor();
  }

  // Getters for modifiers
  int get strengthModifier => getModifier(strength);
  int get dexterityModifier => getModifier(dexterity);
  int get constitutionModifier => getModifier(constitution);
  int get intelligenceModifier => getModifier(intelligence);
  int get wisdomModifier => getModifier(wisdom);
  int get charismaModifier => getModifier(charisma);

  // Derived attributes
  int get initiative => dexterityModifier;
  int get proficiencyBonus => 2 + (level - 1) ~/ 4;

  // Weight calculations (lbs)
  double get totalWeight {
    return inventory.fold(0.0, (sum, item) => sum + (item.weight * item.quantity));
  }
  
  double get carryingCapacity => strength * 15.0;

  // Calculate modifier for a specific skill definition
  int getSkillModifier(SkillDefinition skill) {
    int baseAttrMod = 0;
    switch (skill.attribute) {
      case 'FOR':
        baseAttrMod = strengthModifier;
        break;
      case 'DES':
        baseAttrMod = dexterityModifier;
        break;
      case 'CON':
        baseAttrMod = constitutionModifier;
        break;
      case 'INT':
        baseAttrMod = intelligenceModifier;
        break;
      case 'SAB':
        baseAttrMod = wisdomModifier;
        break;
      case 'CAR':
        baseAttrMod = charismaModifier;
        break;
    }
    
    if (proficientSkills.contains(skill.id)) {
      return baseAttrMod + proficiencyBonus;
    }
    return baseAttrMod;
  }

  CharacterState copyWith({
    String? name,
    String? characterClass,
    String? characterRace,
    int? hp,
    int? maxHp,
    int? mana,
    int? maxMana,
    int? level,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    int? armorClass,
    List<InventoryItem>? inventory,
    int? gold,
    int? silver,
    int? copper,
    List<CharacterAttack>? attacks,
    Set<String>? proficientSkills,
  }) {
    return CharacterState(
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      characterRace: characterRace ?? this.characterRace,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      level: level ?? this.level,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      armorClass: armorClass ?? this.armorClass,
      inventory: inventory ?? this.inventory,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      copper: copper ?? this.copper,
      attacks: attacks ?? this.attacks,
      proficientSkills: proficientSkills ?? this.proficientSkills,
    );
  }
}

class CharacterNotifier extends Notifier<CharacterState> {
  static const _keyName = 'char_name';
  static const _keyClass = 'char_class';
  static const _keyRace = 'char_race';
  static const _keyHp = 'char_hp';
  static const _keyMaxHp = 'char_max_hp';
  static const _keyMana = 'char_mana';
  static const _keyMaxMana = 'char_max_mana';
  static const _keyLevel = 'char_level';
  
  // SharedPreferences keys for attributes
  static const _keyStr = 'char_str';
  static const _keyDex = 'char_dex';
  static const _keyCon = 'char_con';
  static const _keyInt = 'char_int';
  static const _keyWis = 'char_wis';
  static const _keyCha = 'char_cha';
  static const _keyAc = 'char_ac';

  // SharedPreferences keys for inventory and wealth
  static const _keyInventory = 'char_inventory';
  static const _keyGold = 'char_gold';
  static const _keySilver = 'char_silver';
  static const _keyCopper = 'char_copper';

  // SharedPreferences keys for attacks
  static const _keyAttacks = 'char_attacks';

  // SharedPreferences keys for skills
  static const _keySkills = 'char_proficient_skills';

  @override
  CharacterState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    
    // Parse inventory from JSON string
    final inventoryJson = prefs.getString(_keyInventory);
    List<InventoryItem> loadedInventory = [];
    if (inventoryJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(inventoryJson);
        loadedInventory = decodedList.map((m) => InventoryItem.fromMap(m)).toList();
      } catch (_) {
        loadedInventory = [];
      }
    }

    // Parse attacks from JSON string
    final attacksJson = prefs.getString(_keyAttacks);
    List<CharacterAttack> loadedAttacks = [];
    if (attacksJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(attacksJson);
        loadedAttacks = decodedList.map((m) => CharacterAttack.fromMap(m)).toList();
      } catch (_) {
        loadedAttacks = [];
      }
    }

    // Parse proficient skills
    final skillsJson = prefs.getString(_keySkills);
    Set<String> loadedSkills = {};
    if (skillsJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(skillsJson);
        loadedSkills = decodedList.cast<String>().toSet();
      } catch (_) {
        loadedSkills = {};
      }
    }

    return CharacterState(
      name: prefs.getString(_keyName) ?? 'Herói Sem Nome',
      characterClass: prefs.getString(_keyClass) ?? 'Guerreiro',
      characterRace: prefs.getString(_keyRace) ?? 'Humano',
      hp: prefs.getInt(_keyHp) ?? 10,
      maxHp: prefs.getInt(_keyMaxHp) ?? 10,
      mana: prefs.getInt(_keyMana) ?? 5,
      maxMana: prefs.getInt(_keyMaxMana) ?? 5,
      level: prefs.getInt(_keyLevel) ?? 1,
      strength: prefs.getInt(_keyStr) ?? 10,
      dexterity: prefs.getInt(_keyDex) ?? 10,
      constitution: prefs.getInt(_keyCon) ?? 10,
      intelligence: prefs.getInt(_keyInt) ?? 10,
      wisdom: prefs.getInt(_keyWis) ?? 10,
      charisma: prefs.getInt(_keyCha) ?? 10,
      armorClass: prefs.getInt(_keyAc) ?? 10,
      inventory: loadedInventory,
      gold: prefs.getInt(_keyGold) ?? 0,
      silver: prefs.getInt(_keySilver) ?? 0,
      copper: prefs.getInt(_keyCopper) ?? 0,
      attacks: loadedAttacks,
      proficientSkills: loadedSkills,
    );
  }

  void _saveInventory(List<InventoryItem> items) {
    final jsonStr = jsonEncode(items.map((i) => i.toMap()).toList());
    ref.read(sharedPreferencesProvider).setString(_keyInventory, jsonStr);
  }

  void _saveAttacks(List<CharacterAttack> attacks) {
    final jsonStr = jsonEncode(attacks.map((a) => a.toMap()).toList());
    ref.read(sharedPreferencesProvider).setString(_keyAttacks, jsonStr);
  }

  void _saveSkills(Set<String> skills) {
    final jsonStr = jsonEncode(skills.toList());
    ref.read(sharedPreferencesProvider).setString(_keySkills, jsonStr);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
    ref.read(sharedPreferencesProvider).setString(_keyName, name);
  }

  void updateClass(String charClass) {
    state = state.copyWith(characterClass: charClass);
    ref.read(sharedPreferencesProvider).setString(_keyClass, charClass);
  }

  void updateRace(String charRace) {
    state = state.copyWith(characterRace: charRace);
    ref.read(sharedPreferencesProvider).setString(_keyRace, charRace);
  }

  void incrementHp() {
    if (state.hp < state.maxHp) {
      state = state.copyWith(hp: state.hp + 1);
      ref.read(sharedPreferencesProvider).setInt(_keyHp, state.hp);
    }
  }

  void decrementHp() {
    if (state.hp > 0) {
      state = state.copyWith(hp: state.hp - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyHp, state.hp);
    }
  }

  void incrementMaxHp() {
    state = state.copyWith(maxHp: state.maxHp + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyMaxHp, state.maxHp);
  }

  void decrementMaxHp() {
    if (state.maxHp > 1) {
      int newHp = state.hp;
      if (newHp > state.maxHp - 1) {
        newHp = state.maxHp - 1;
      }
      state = state.copyWith(maxHp: state.maxHp - 1, hp: newHp);
      ref.read(sharedPreferencesProvider).setInt(_keyMaxHp, state.maxHp);
      ref.read(sharedPreferencesProvider).setInt(_keyHp, state.hp);
    }
  }

  void incrementMana() {
    if (state.mana < state.maxMana) {
      state = state.copyWith(mana: state.mana + 1);
      ref.read(sharedPreferencesProvider).setInt(_keyMana, state.mana);
    }
  }

  void decrementMana() {
    if (state.mana > 0) {
      state = state.copyWith(mana: state.mana - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyMana, state.mana);
    }
  }

  void incrementMaxMana() {
    state = state.copyWith(maxMana: state.maxMana + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyMaxMana, state.maxMana);
  }

  void decrementMaxMana() {
    if (state.maxMana > 1) {
      int newMana = state.mana;
      if (newMana > state.maxMana - 1) {
        newMana = state.maxMana - 1;
      }
      state = state.copyWith(maxMana: state.maxMana - 1, mana: newMana);
      ref.read(sharedPreferencesProvider).setInt(_keyMaxMana, state.maxMana);
      ref.read(sharedPreferencesProvider).setInt(_keyMana, state.mana);
    }
  }

  void incrementLevel() {
    state = state.copyWith(level: state.level + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyLevel, state.level);
  }

  void decrementLevel() {
    if (state.level > 1) {
      state = state.copyWith(level: state.level - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyLevel, state.level);
    }
  }

  // Core Attributes modifications
  void incrementStrength() {
    state = state.copyWith(strength: state.strength + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyStr, state.strength);
  }

  void decrementStrength() {
    if (state.strength > 1) {
      state = state.copyWith(strength: state.strength - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyStr, state.strength);
    }
  }

  void incrementDexterity() {
    state = state.copyWith(dexterity: state.dexterity + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyDex, state.dexterity);
  }

  void decrementDexterity() {
    if (state.dexterity > 1) {
      state = state.copyWith(dexterity: state.dexterity - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyDex, state.dexterity);
    }
  }

  void incrementConstitution() {
    state = state.copyWith(constitution: state.constitution + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyCon, state.constitution);
  }

  void decrementConstitution() {
    if (state.constitution > 1) {
      state = state.copyWith(constitution: state.constitution - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyCon, state.constitution);
    }
  }

  void incrementIntelligence() {
    state = state.copyWith(intelligence: state.intelligence + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyInt, state.intelligence);
  }

  void decrementIntelligence() {
    if (state.intelligence > 1) {
      state = state.copyWith(intelligence: state.intelligence - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyInt, state.intelligence);
    }
  }

  void incrementWisdom() {
    state = state.copyWith(wisdom: state.wisdom + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyWis, state.wisdom);
  }

  void decrementWisdom() {
    if (state.wisdom > 1) {
      state = state.copyWith(wisdom: state.wisdom - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyWis, state.wisdom);
    }
  }

  void incrementCharisma() {
    state = state.copyWith(charisma: state.charisma + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyCha, state.charisma);
  }

  void decrementCharisma() {
    if (state.charisma > 1) {
      state = state.copyWith(charisma: state.charisma - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyCha, state.charisma);
    }
  }

  // Armor Class modifications
  void incrementArmorClass() {
    state = state.copyWith(armorClass: state.armorClass + 1);
    ref.read(sharedPreferencesProvider).setInt(_keyAc, state.armorClass);
  }

  void decrementArmorClass() {
    if (state.armorClass > 1) {
      state = state.copyWith(armorClass: state.armorClass - 1);
      ref.read(sharedPreferencesProvider).setInt(_keyAc, state.armorClass);
    }
  }

  // Inventory Methods
  void addInventoryItem(InventoryItem item) {
    final updatedList = [...state.inventory, item];
    state = state.copyWith(inventory: updatedList);
    _saveInventory(updatedList);
  }

  void updateInventoryItem(InventoryItem item) {
    final updatedList = state.inventory.map((i) => i.id == item.id ? item : i).toList();
    state = state.copyWith(inventory: updatedList);
    _saveInventory(updatedList);
  }

  void removeInventoryItem(String id) {
    final updatedList = state.inventory.where((i) => i.id != id).toList();
    state = state.copyWith(inventory: updatedList);
    _saveInventory(updatedList);
  }

  // Wealth Methods
  void setGold(int val) {
    if (val >= 0) {
      state = state.copyWith(gold: val);
      ref.read(sharedPreferencesProvider).setInt(_keyGold, val);
    }
  }

  void setSilver(int val) {
    if (val >= 0) {
      state = state.copyWith(silver: val);
      ref.read(sharedPreferencesProvider).setInt(_keySilver, val);
    }
  }

  void setCopper(int val) {
    if (val >= 0) {
      state = state.copyWith(copper: val);
      ref.read(sharedPreferencesProvider).setInt(_keyCopper, val);
    }
  }

  // Attack Methods
  void addAttack(CharacterAttack attack) {
    final updatedList = [...state.attacks, attack];
    state = state.copyWith(attacks: updatedList);
    _saveAttacks(updatedList);
  }

  void updateAttack(CharacterAttack attack) {
    final updatedList = state.attacks.map((a) => a.id == attack.id ? attack : a).toList();
    state = state.copyWith(attacks: updatedList);
    _saveAttacks(updatedList);
  }

  void removeAttack(String id) {
    final updatedList = state.attacks.where((a) => a.id != id).toList();
    state = state.copyWith(attacks: updatedList);
    _saveAttacks(updatedList);
  }

  // Skill Methods
  void toggleSkillProficiency(String skillId) {
    final updatedSkills = Set<String>.from(state.proficientSkills);
    if (updatedSkills.contains(skillId)) {
      updatedSkills.remove(skillId);
    } else {
      updatedSkills.add(skillId);
    }
    state = state.copyWith(proficientSkills: updatedSkills);
    _saveSkills(updatedSkills);
  }

  // Long Rest
  void longRest() {
    state = state.copyWith(hp: state.maxHp, mana: state.maxMana);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt(_keyHp, state.maxHp);
    prefs.setInt(_keyMana, state.maxMana);
  }
}

final counterProvider = NotifierProvider<CharacterNotifier, CharacterState>(() {
  return CharacterNotifier();
});

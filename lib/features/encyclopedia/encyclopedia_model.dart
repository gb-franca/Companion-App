enum EncyclopediaType { spell, creature, item }

class EncyclopediaItem {
  final String key;
  final String name;
  final EncyclopediaType type;
  final String subtitle;
  final String description;
  final Map<String, dynamic> details;

  EncyclopediaItem({
    required this.key,
    required this.name,
    required this.type,
    required this.subtitle,
    required this.description,
    required this.details,
  });

  factory EncyclopediaItem.fromSpellJson(Map<String, dynamic> json) {
    final schoolName = json['school'] is Map ? (json['school']['name'] ?? '') : '';
    final level = json['level'] ?? 0;
    final levelStr = level == 0 ? 'Truque' : 'Nível $level';
    
    return EncyclopediaItem(
      key: json['key'] ?? json['slug'] ?? json['name'],
      name: json['name'] ?? '',
      type: EncyclopediaType.spell,
      subtitle: '$levelStr • $schoolName',
      description: json['desc'] ?? '',
      details: {
        'level': level,
        'school': schoolName,
        'range': json['range_text'] ?? json['range'] ?? '',
        'duration': json['duration'] ?? '',
        'concentration': json['concentration'] == true ? 'Sim' : 'Não',
        'casting_time': json['casting_time'] ?? '',
        'ritual': json['ritual'] == true ? 'Sim' : 'Não',
        'components': [
          if (json['verbal'] == true) 'V',
          if (json['somatic'] == true) 'S',
          if (json['material'] == true) 'M',
        ].join(', '),
        'material_specified': json['material_specified'] ?? '',
      },
    );
  }

  factory EncyclopediaItem.fromCreatureJson(Map<String, dynamic> json) {
    final typeName = json['type'] is Map ? (json['type']['name'] ?? '') : (json['type'] ?? '');
    final sizeName = json['size'] is Map ? (json['size']['name'] ?? '') : (json['size'] ?? '');
    final cr = json['challenge_rating'] ?? 0.0;
    
    // Format traits/actions into description if description is blank
    final List<dynamic> actions = json['actions'] ?? [];
    final List<dynamic> traits = json['traits'] ?? [];
    final buffer = StringBuffer();
    if (traits.isNotEmpty) {
      buffer.writeln('**Habilidades / Traços:**');
      for (var t in traits) {
        buffer.writeln('- *${t['name']}:* ${t['desc']}');
      }
      buffer.writeln();
    }
    if (actions.isNotEmpty) {
      buffer.writeln('**Ações:**');
      for (var a in actions) {
        buffer.writeln('- *${a['name']}:* ${a['desc']}');
      }
    }
    final desc = buffer.isNotEmpty ? buffer.toString() : 'Nenhuma descrição disponível.';

    return EncyclopediaItem(
      key: json['key'] ?? json['slug'] ?? json['name'],
      name: json['name'] ?? '',
      type: EncyclopediaType.creature,
      subtitle: '$sizeName $typeName • ND $cr',
      description: desc,
      details: {
        'hit_points': json['hit_points'] ?? 0,
        'hit_dice': json['hit_dice'] ?? '',
        'armor_class': json['armor_class'] ?? 0,
        'armor_detail': json['armor_detail'] ?? '',
        'speed': json['speed_all'] is Map ? (json['speed_all']['walk'] ?? json['speed']?['walk'] ?? '') : '',
        'abilities': json['ability_scores'] ?? {},
        'saving_throws': json['saving_throws_all'] ?? {},
        'skills': json['skill_bonuses_all'] ?? {},
        'languages': json['languages'] is Map ? (json['languages']['as_string'] ?? '') : (json['languages'] ?? ''),
        'actions': actions,
        'traits': traits,
      },
    );
  }

  factory EncyclopediaItem.fromItemJson(Map<String, dynamic> json) {
    final categoryName = json['category'] is Map ? (json['category']['name'] ?? '') : (json['category'] ?? '');
    final rarityName = json['rarity'] is Map ? (json['rarity']['name'] ?? '') : (json['rarity'] ?? '');
    
    return EncyclopediaItem(
      key: json['key'] ?? json['slug'] ?? json['name'],
      name: json['name'] ?? '',
      type: EncyclopediaType.item,
      subtitle: '$categoryName • $rarityName',
      description: json['desc'] ?? '',
      details: {
        'category': categoryName,
        'rarity': rarityName,
        'weight': json['weight'] != null ? '${json['weight']} ${json['weight_unit'] ?? "lb"}' : '',
        'cost': json['cost'] ?? '',
        'requires_attunement': json['requires_attunement'] == true ? 'Sim' : 'Não',
        'attunement_detail': json['attunement_detail'] ?? '',
      },
    );
  }
}

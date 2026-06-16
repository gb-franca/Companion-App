import 'package:flutter/material.dart';
import 'encyclopedia_model.dart';

class EncyclopediaDetailScreen extends StatelessWidget {
  final EncyclopediaItem item;

  const EncyclopediaDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(theme),
            const SizedBox(height: 24),

            // Content dynamic sections
            if (item.type == EncyclopediaType.spell)
              _buildSpellDetails(theme)
            else if (item.type == EncyclopediaType.creature)
              _buildCreatureDetails(theme)
            else if (item.type == EncyclopediaType.item)
              _buildItemDetails(theme),

            const SizedBox(height: 24),
            // Description Section
            Text(
              'Descrição / Detalhes',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Text(
                item.description.replaceAll('\\n', '\n'),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    IconData icon;
    Color iconColor;

    switch (item.type) {
      case EncyclopediaType.spell:
        icon = Icons.auto_stories_rounded;
        iconColor = Colors.purpleAccent;
        break;
      case EncyclopediaType.creature:
        icon = Icons.pets_rounded;
        iconColor = Colors.redAccent;
        break;
      case EncyclopediaType.item:
        icon = Icons.backpack_rounded;
        iconColor = Colors.orangeAccent;
        break;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Spell specific attributes view
  Widget _buildSpellDetails(ThemeData theme) {
    final d = item.details;
    return Column(
      children: [
        _buildDetailGrid([
          _DetailGridItem('Tempo de Conconjuração', d['casting_time'] ?? 'N/A'),
          _DetailGridItem('Alcance', d['range'] ?? 'N/A'),
          _DetailGridItem('Duração', d['duration'] ?? 'N/A'),
          _DetailGridItem('Concentração', d['concentration'] ?? 'N/A'),
          _DetailGridItem('Ritual', d['ritual'] ?? 'N/A'),
          _DetailGridItem('Componentes', d['components'] ?? 'N/A'),
        ]),
        if (d['material_specified'] != null && d['material_specified'].toString().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoRow(theme, 'Especificação do Material:', d['material_specified']),
        ]
      ],
    );
  }

  // Magic Item specific attributes view
  Widget _buildItemDetails(ThemeData theme) {
    final d = item.details;
    return _buildDetailGrid([
      _DetailGridItem('Categoria', d['category'] ?? 'N/A'),
      _DetailGridItem('Raridade', d['rarity'] ?? 'N/A'),
      _DetailGridItem('Peso', d['weight'] != '' ? d['weight'] : 'N/A'),
      _DetailGridItem('Custo', d['cost'] != '' ? d['cost'] : 'N/A'),
      _DetailGridItem('Requer Sintonização', d['requires_attunement'] ?? 'N/A'),
      _DetailGridItem('Detalhe Sintonização', d['attunement_detail'] != '' ? d['attunement_detail'] : 'N/A'),
    ]);
  }

  // Creature specific stats layout (RPG Style)
  Widget _buildCreatureDetails(ThemeData theme) {
    final d = item.details;
    final abilities = d['abilities'] as Map<dynamic, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Stats (AC, HP, Speed)
        _buildDetailGrid([
          _DetailGridItem('Classe de Armadura (CA)', '${d['armor_class'] ?? 0} ${d['armor_detail'] ?? ""}'),
          _DetailGridItem('Pontos de Vida (HP)', '${d['hit_points'] ?? 0} (${d['hit_dice'] ?? ""})'),
          _DetailGridItem('Deslocamento (Caminhada)', '${d['speed'] ?? "N/A"}'),
          _DetailGridItem('Idiomas', d['languages'] ?? 'N/A'),
        ]),
        const SizedBox(height: 20),

        // Ability Scores Title
        Text(
          'Atributos',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Ability scores grid: STR, DEX, CON, INT, WIS, CHA
        if (abilities.isNotEmpty)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 6,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.75,
            children: [
              _buildAbilityScoreCard(theme, 'FOR', abilities['strength']),
              _buildAbilityScoreCard(theme, 'DES', abilities['dexterity']),
              _buildAbilityScoreCard(theme, 'CON', abilities['constitution']),
              _buildAbilityScoreCard(theme, 'INT', abilities['intelligence']),
              _buildAbilityScoreCard(theme, 'SAB', abilities['wisdom']),
              _buildAbilityScoreCard(theme, 'CAR', abilities['charisma']),
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAbilityScoreCard(ThemeData theme, String name, dynamic score) {
    final int scoreVal = score is int ? score : (int.tryParse(score?.toString() ?? '') ?? 10);
    // Modifier: (score - 10) / 2 floored
    final mod = ((scoreVal - 10) / 2).floor();
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              '$scoreVal',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              modStr,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(List<_DetailGridItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DetailGridItem {
  final String label;
  final String value;

  _DetailGridItem(this.label, this.value);
}

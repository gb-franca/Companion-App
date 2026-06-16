import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'encyclopedia_provider.dart';
import 'encyclopedia_model.dart';
import 'encyclopedia_detail_screen.dart';

class EncyclopediaScreen extends ConsumerStatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  ConsumerState<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends ConsumerState<EncyclopediaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(encyclopediaProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquise por nome...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(encyclopediaProvider.notifier).setQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                  onSubmitted: (val) {
                    ref.read(encyclopediaProvider.notifier).setQuery(val.trim());
                  },
                ),
                const SizedBox(height: 12),

                // Category Tabs (Spell, Creature, Item)
                Row(
                  children: [
                    _buildCategoryTab(
                      label: 'Magias',
                      type: EncyclopediaType.spell,
                      currentType: state.type,
                      icon: Icons.auto_stories_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryTab(
                      label: 'Monstros',
                      type: EncyclopediaType.creature,
                      currentType: state.type,
                      icon: Icons.pets_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryTab(
                      label: 'Itens',
                      type: EncyclopediaType.item,
                      currentType: state.type,
                      icon: Icons.backpack_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results Area
          Expanded(
            child: state.results.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhum resultado encontrado.',
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, idx) {
                    final item = items[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: theme.hintColor, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EncyclopediaDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Erro de rede ou de conexão à API.',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verifique sua conexão e tente novamente. Detalhe: $err',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(encyclopediaProvider.notifier).search();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Tentar Novamente'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required EncyclopediaType type,
    required EncyclopediaType currentType,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = type == currentType;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            ref.read(encyclopediaProvider.notifier).setType(type);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

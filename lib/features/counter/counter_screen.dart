import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'counter_provider.dart';
import '../dice_roller/dice_roller_provider.dart';

class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _skillSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(counterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: theme.colorScheme.surface,
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.hintColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Ficha'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Combate'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.backpack_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Mochila'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Character stats
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CharacterHeaderCard(state: state),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _HpCounterCard(state: state)),
                          const SizedBox(width: 16),
                          Expanded(child: _ManaCounterCard(state: state)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _HpCounterCard(state: state),
                          const SizedBox(height: 16),
                          _ManaCounterCard(state: state),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.military_tech_rounded, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Atributos de Habilidade',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _AttributesGrid(state: state),
                const SizedBox(height: 28),
                
                // Skills & Proficiencies Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology_rounded, color: theme.colorScheme.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Perícias e Proficiências',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar perícia...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _skillSearchQuery = val.toLowerCase();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSkillsList(state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab 2: Combat & Attacks
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                          child: Icon(Icons.casino_rounded, color: theme.colorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ataques Rápidos',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Adicione suas armas e feitiços para rolar acertos e danos em um clique.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Attacks Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gavel_rounded, color: theme.colorScheme.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Ações de Ataque',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAttackDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Novo Ataque'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Attacks List
                _AttacksList(state: state, onRoll: _showRollDialog),
              ],
            ),
          ),

          // Tab 3: Backpack & Wealth
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WealthTracker(state: state),
                const SizedBox(height: 20),
                _CarryingCapacityCard(state: state),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory_2_rounded, color: theme.colorScheme.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Mochila e Equipamentos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showItemDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Novo Item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InventoryList(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsList(CharacterState state) {
    final filtered = skillDefinitions
        .where((s) => s.name.toLowerCase().contains(_skillSearchQuery))
        .toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text('Nenhuma perícia encontrada.'),
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final skill = filtered[index];
        final isProficient = state.proficientSkills.contains(skill.id);
        final mod = state.getSkillModifier(skill);
        final modStr = mod >= 0 ? '+$mod' : '$mod';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: IconButton(
            icon: Icon(
              isProficient ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: isProficient ? theme.colorScheme.primary : theme.disabledColor,
            ),
            tooltip: isProficient ? 'Remover Proficiência' : 'Adicionar Proficiência',
            onPressed: () {
              ref.read(counterProvider.notifier).toggleSkillProficiency(skill.id);
            },
          ),
          title: Row(
            children: [
              Text(
                skill.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text(
                '(${skill.attribute})',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isProficient
                      ? theme.colorScheme.primary.withOpacity(0.08)
                      : theme.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  modStr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isProficient ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.casino_rounded, size: 18),
                tooltip: 'Rolar Teste de ${skill.name}',
                onPressed: () {
                  _showRollDialog(context, 'Perícia: ${skill.name}', 'd20', mod);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRollDialog(BuildContext context, String title, String notation, int modifier) {
    ref.read(diceRollerProvider.notifier).roll(notation, modifier: modifier);
    final lastRoll = ref.read(diceRollerProvider).lastRoll!;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isD20 = notation.toLowerCase().trim() == 'd20';
        final isNat20 = isD20 && lastRoll.result == 20;
        final isNat1 = isD20 && lastRoll.result == 1;

        Color resultColor = theme.colorScheme.primary;
        String specialText = '';
        if (isNat20) {
          resultColor = Colors.green;
          specialText = '💥 CRÍTICO! (Natural 20)';
        } else if (isNat1) {
          resultColor = Colors.red;
          specialText = '☠️ FALHA CRÍTICA! (Natural 1)';
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Center(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fórmula: $notation ${modifier >= 0 ? "+$modifier" : "$modifier"}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 44,
                backgroundColor: resultColor.withOpacity(0.1),
                child: Text(
                  '${lastRoll.total}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rolagem: ${lastRoll.result} (dado) + $modifier (bônus)',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (specialText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  specialText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: resultColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (lastRoll.individualRolls.length > 1) ...[
                const SizedBox(height: 12),
                Text(
                  'Dados individuais: ${lastRoll.individualRolls.join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            )
          ],
        );
      },
    );
  }

  void _showAttackDialog(BuildContext context, [CharacterAttack? attack]) {
    final isEdit = attack != null;
    final nameController = TextEditingController(text: attack?.name ?? '');
    final hitController = TextEditingController(text: attack?.hitBonus.toString() ?? '0');
    final diceController = TextEditingController(text: attack?.damageDice ?? '1d6');
    final dmgController = TextEditingController(text: attack?.damageBonus.toString() ?? '0');
    final notesController = TextEditingController(text: attack?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Ataque' : 'Novo Ataque'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Ação/Arma',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mod. de Acerto',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.gps_fixed_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: diceController,
                        decoration: const InputDecoration(
                          labelText: 'Dados de Dano',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.casino_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dmgController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mod. de Dano',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_circle_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Ex: Cortante)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final hit = int.tryParse(hitController.text) ?? 0;
                final dice = diceController.text.trim();
                final dmg = int.tryParse(dmgController.text) ?? 0;
                final notes = notesController.text.trim();

                if (isEdit) {
                  ref.read(counterProvider.notifier).updateAttack(
                        attack.copyWith(
                          name: name,
                          hitBonus: hit,
                          damageDice: dice,
                          damageBonus: dmg,
                          notes: notes,
                        ),
                      );
                } else {
                  ref.read(counterProvider.notifier).addAttack(
                        CharacterAttack(
                          id: const Uuid().v4(),
                          name: name,
                          hitBonus: hit,
                          damageDice: dice,
                          damageBonus: dmg,
                          notes: notes,
                        ),
                      );
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDialog(BuildContext context, [InventoryItem? item]) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final qtyController = TextEditingController(text: item?.quantity.toString() ?? '1');
    final weightController = TextEditingController(text: item?.weight.toString() ?? '0.0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Item' : 'Novo Item na Mochila'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Item',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrição / Notas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.unfold_more_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Peso (lbs)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monitor_weight_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final qty = int.tryParse(qtyController.text) ?? 1;
                final weight = double.tryParse(weightController.text) ?? 0.0;
                final desc = descController.text.trim();

                if (isEdit) {
                  ref.read(counterProvider.notifier).updateInventoryItem(
                        item.copyWith(
                          name: name,
                          quantity: qty,
                          weight: weight,
                          description: desc,
                        ),
                      );
                } else {
                  ref.read(counterProvider.notifier).addInventoryItem(
                        InventoryItem(
                          id: const Uuid().v4(),
                          name: name,
                          quantity: qty,
                          weight: weight,
                          description: desc,
                        ),
                      );
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}

class _CharacterHeaderCard extends ConsumerWidget {
  final CharacterState state;

  const _CharacterHeaderCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.secondary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.characterRace} ${state.characterClass} • Nível ${state.level}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.nightlight_round, color: Colors.indigoAccent),
                  onPressed: () {
                    ref.read(counterProvider.notifier).longRest();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Descanso Longo realizado! Vida e Mana restauradas.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Descanso Longo (Recupera HP/Mana)',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _showEditCharacterDialog(context, ref, state),
                  tooltip: 'Editar Detalhes',
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(
                  context,
                  label: 'Nível',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () => ref.read(counterProvider.notifier).decrementLevel(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          '${state.level}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => ref.read(counterProvider.notifier).incrementLevel(),
                      ),
                    ],
                  ),
                ),
                _buildHeaderStat(
                  context,
                  label: 'Proficiência',
                  child: Text(
                    '+${state.proficiencyBonus}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                _buildHeaderStat(
                  context,
                  label: 'Iniciativa',
                  child: Text(
                    state.initiative >= 0 ? '+${state.initiative}' : '${state.initiative}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                _buildHeaderStat(
                  context,
                  label: 'Classe Armad. (CA)',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove, size: 14),
                        onPressed: () => ref.read(counterProvider.notifier).decrementArmorClass(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          '${state.armorClass}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add, size: 14),
                        onPressed: () => ref.read(counterProvider.notifier).incrementArmorClass(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, {required String label, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.hintColor,
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  void _showEditCharacterDialog(BuildContext context, WidgetRef ref, CharacterState state) {
    final nameController = TextEditingController(text: state.name);
    final raceController = TextEditingController(text: state.characterRace);
    final classController = TextEditingController(text: state.characterClass);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes do Personagem'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: raceController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Raça',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: classController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Classe',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final race = raceController.text.trim();
                final cls = classController.text.trim();
                
                if (name.isNotEmpty) {
                  ref.read(counterProvider.notifier).updateName(name);
                }
                if (race.isNotEmpty) {
                  ref.read(counterProvider.notifier).updateRace(race);
                }
                if (cls.isNotEmpty) {
                  ref.read(counterProvider.notifier).updateClass(cls);
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}

class _HpCounterCard extends ConsumerWidget {
  final CharacterState state;
  const _HpCounterCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hpPercent = state.maxHp > 0 ? (state.hp / state.maxHp).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Vida (HP)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => ref.read(counterProvider.notifier).decrementMaxHp(),
                      tooltip: 'Diminuir HP Máximo',
                    ),
                    Text(
                      'Max: ${state.maxHp}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => ref.read(counterProvider.notifier).incrementMaxHp(),
                      tooltip: 'Aumentar HP Máximo',
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${state.hp} / ${state.maxHp}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: hpPercent,
                minHeight: 10,
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.red.withOpacity(0.15)
                    : Colors.red.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(counterProvider.notifier).decrementHp(),
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Dano'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(counterProvider.notifier).incrementHp(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Cura'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class _ManaCounterCard extends ConsumerWidget {
  final CharacterState state;
  const _ManaCounterCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final manaPercent = state.maxMana > 0 ? (state.mana / state.maxMana).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.blueAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Mana (MP)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => ref.read(counterProvider.notifier).decrementMaxMana(),
                      tooltip: 'Diminuir Mana Máxima',
                    ),
                    Text(
                      'Max: ${state.maxMana}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => ref.read(counterProvider.notifier).incrementMaxMana(),
                      tooltip: 'Aumentar Mana Máxima',
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${state.mana} / ${state.maxMana}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: manaPercent,
                minHeight: 10,
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.blue.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(counterProvider.notifier).decrementMana(),
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Gastar'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(counterProvider.notifier).incrementMana(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Recuperar'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class _AttributesGrid extends ConsumerWidget {
  final CharacterState state;
  const _AttributesGrid({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 600 ? 6 : (width >= 400 ? 3 : 2);

    final attributes = [
      {
        'abbr': 'FOR',
        'value': state.strength,
        'mod': state.strengthModifier,
        'color': Colors.redAccent,
        'inc': () => ref.read(counterProvider.notifier).incrementStrength(),
        'dec': () => ref.read(counterProvider.notifier).decrementStrength(),
      },
      {
        'abbr': 'DES',
        'value': state.dexterity,
        'mod': state.dexterityModifier,
        'color': Colors.orangeAccent,
        'inc': () => ref.read(counterProvider.notifier).incrementDexterity(),
        'dec': () => ref.read(counterProvider.notifier).decrementDexterity(),
      },
      {
        'abbr': 'CON',
        'value': state.constitution,
        'mod': state.constitutionModifier,
        'color': Colors.greenAccent,
        'inc': () => ref.read(counterProvider.notifier).incrementConstitution(),
        'dec': () => ref.read(counterProvider.notifier).decrementConstitution(),
      },
      {
        'abbr': 'INT',
        'value': state.intelligence,
        'mod': state.intelligenceModifier,
        'color': Colors.blueAccent,
        'inc': () => ref.read(counterProvider.notifier).incrementIntelligence(),
        'dec': () => ref.read(counterProvider.notifier).decrementIntelligence(),
      },
      {
        'abbr': 'SAB',
        'value': state.wisdom,
        'mod': state.wisdomModifier,
        'color': Colors.purpleAccent,
        'inc': () => ref.read(counterProvider.notifier).incrementWisdom(),
        'dec': () => ref.read(counterProvider.notifier).decrementWisdom(),
      },
      {
        'abbr': 'CAR',
        'value': state.charisma,
        'mod': state.charismaModifier,
        'color': Colors.pinkAccent,
        'inc': () => ref.read(counterProvider.notifier).incrementCharisma(),
        'dec': () => ref.read(counterProvider.notifier).decrementCharisma(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: attributes.length,
      itemBuilder: (context, index) {
        final attr = attributes[index];
        final theme = Theme.of(context);
        final modVal = attr['mod'] as int;
        final modStr = modVal >= 0 ? '+$modVal' : '$modVal';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: (attr['color'] as Color).withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (attr['abbr'] as String).toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: (attr['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  modStr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: attr['color'] as Color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(2),
                    icon: const Icon(Icons.remove, size: 14),
                    onPressed: attr['dec'] as VoidCallback,
                  ),
                  Text(
                    '${attr['value']}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(2),
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: attr['inc'] as VoidCallback,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WealthTracker extends ConsumerWidget {
  final CharacterState state;
  const _WealthTracker({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tesouro e Riquezas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCoinCard(
                    context,
                    label: 'Ouro (PO)',
                    value: state.gold,
                    color: const Color(0xFFFFD700),
                    onTap: () => _showCoinAdjustmentDialog(context, ref, 'Ouro', state.gold, (val) {
                      ref.read(counterProvider.notifier).setGold(val);
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCoinCard(
                    context,
                    label: 'Prata (PP)',
                    value: state.silver,
                    color: const Color(0xFFC0C0C0),
                    onTap: () => _showCoinAdjustmentDialog(context, ref, 'Prata', state.silver, (val) {
                      ref.read(counterProvider.notifier).setSilver(val);
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCoinCard(
                    context,
                    label: 'Cobre (PC)',
                    value: state.copper,
                    color: const Color(0xFFCD7F32),
                    onTap: () => _showCoinAdjustmentDialog(context, ref, 'Cobre', state.copper, (val) {
                      ref.read(counterProvider.notifier).setCopper(val);
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinCard(BuildContext context,
      {required String label, required int value, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle_rounded, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$value',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCoinAdjustmentDialog(
      BuildContext context, WidgetRef ref, String coinName, int currentValue, Function(int) onSave) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajustar Moedas de $coinName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Quantidade de moedas',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      final val = int.tryParse(controller.text) ?? 0;
                      if (val > 0) controller.text = (val - 1).toString();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      final val = int.tryParse(controller.text) ?? 0;
                      controller.text = (val + 1).toString();
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                onSave(val);
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}

class _CarryingCapacityCard extends StatelessWidget {
  final CharacterState state;
  const _CarryingCapacityCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weight = state.totalWeight;
    final capacity = state.carryingCapacity;
    final percent = capacity > 0 ? (weight / capacity).clamp(0.0, 1.0) : 0.0;

    Color barColor = Colors.green;
    if (percent > 0.85) {
      barColor = Colors.redAccent;
    } else if (percent > 0.6) {
      barColor = Colors.orangeAccent;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monitor_weight_rounded, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Capacidade de Carga',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '${weight.toStringAsFixed(1)} / ${capacity.toStringAsFixed(0)} lbs',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            if (percent >= 1.0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '⚠️ Sobrecarregado! Movimento reduzido.',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InventoryList extends ConsumerWidget {
  final CharacterState state;
  const _InventoryList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (state.inventory.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.backpack_rounded, size: 48, color: theme.disabledColor),
              const SizedBox(height: 12),
              Text(
                'Sua mochila está vazia',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Clique em "Novo Item" para adicionar equipamentos.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.inventory.length,
      itemBuilder: (context, index) {
        final item = state.inventory[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                'x${item.quantity}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description.isNotEmpty) ...[
                  Text(item.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                ],
                Text(
                  'Peso: ${(item.weight * item.quantity).toStringAsFixed(1)} lbs (${item.weight} lbs/u)',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: () => context.findAncestorStateOfType<_CounterScreenState>()?._showItemDialog(context, item),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 20, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteItem(context, ref, item),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteItem(BuildContext context, WidgetRef ref, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Item'),
          content: Text('Tem certeza que deseja remover "${item.name}" da sua mochila?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                ref.read(counterProvider.notifier).removeInventoryItem(item.id);
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

class _AttacksList extends ConsumerWidget {
  final CharacterState state;
  final Function(BuildContext, String, String, int) onRoll;

  const _AttacksList({required this.state, required this.onRoll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (state.attacks.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.gavel_rounded, size: 48, color: theme.disabledColor),
              const SizedBox(height: 12),
              Text(
                'Nenhum ataque cadastrado',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Clique em "Novo Ataque" para adicionar armas ou magias na sua ficha.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.attacks.length,
      itemBuilder: (context, index) {
        final attack = state.attacks[index];
        final hitStr = attack.hitBonus >= 0 ? '+${attack.hitBonus}' : '${attack.hitBonus}';
        final dmgStr = '${attack.damageDice}${attack.damageBonus >= 0 ? "+${attack.damageBonus}" : attack.damageBonus}';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attack.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (attack.notes.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              attack.notes,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () => context.findAncestorStateOfType<_CounterScreenState>()?._showAttackDialog(context, attack),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, size: 20, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteAttack(context, ref, attack),
                          tooltip: 'Excluir',
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                // Roller buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onRoll(context, 'Ataque: ${attack.name}', 'd20', attack.hitBonus),
                        icon: const Icon(Icons.gps_fixed_rounded, size: 16),
                        label: Text('Acerto ($hitStr)'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onRoll(context, 'Dano: ${attack.name}', attack.damageDice, attack.damageBonus),
                        icon: const Icon(Icons.casino_rounded, size: 16),
                        label: Text('Dano ($dmgStr)'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.08),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteAttack(BuildContext context, WidgetRef ref, CharacterAttack attack) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Ataque'),
          content: Text('Tem certeza que deseja remover "${attack.name}" da sua ficha?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                ref.read(counterProvider.notifier).removeAttack(attack.id);
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

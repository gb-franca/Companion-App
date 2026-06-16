import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'campaign_model.dart';
import 'campaigns_provider.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  Campaign? _selectedCampaign;

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignsProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    return Scaffold(
      body: campaignsAsync.when(
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_rounded,
                    size: 64,
                    color: Theme.of(context).hintColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma campanha criada ainda.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCampaignForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Iniciar Nova Campanha'),
                  ),
                ],
              ),
            );
          }

          // If selected campaign is not null but it's no longer in the list (e.g., deleted), reset it.
          if (_selectedCampaign != null && !campaigns.any((c) => c.id == _selectedCampaign!.id)) {
            _selectedCampaign = null;
          }

          // Automatically select first campaign on wide screen if none selected
          if (isWide && _selectedCampaign == null && campaigns.isNotEmpty) {
            _selectedCampaign = campaigns.first;
          }

          final listWidget = ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              final isSelected = _selectedCampaign?.id == campaign.id;

              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                    : null,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    campaign.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 14, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(campaign.system),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDateTimeStr(campaign.nextSession),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    if (isWide) {
                      setState(() {
                        _selectedCampaign = campaign;
                      });
                    } else {
                      _showCampaignDetails(context, campaign);
                    }
                  },
                ),
              );
            },
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: listWidget,
                ),
                VerticalDivider(
                  width: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
                Expanded(
                  flex: 5,
                  child: _selectedCampaign != null
                      ? _CampaignDetailView(
                          campaign: _selectedCampaign!,
                          onEdit: () => _showCampaignForm(context, campaign: _selectedCampaign),
                          onDelete: () => _confirmDelete(context, _selectedCampaign!),
                        )
                      : const Center(child: Text('Selecione uma campanha')),
                ),
              ],
            );
          }

          return listWidget;
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erro ao carregar campanhas: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCampaignForm(context),
        tooltip: 'Nova Campanha',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCampaignDetails(BuildContext context, Campaign campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: _CampaignDetailView(
                campaign: campaign,
                onEdit: () {
                  Navigator.pop(context);
                  _showCampaignForm(context, campaign: campaign);
                },
                onDelete: () {
                  Navigator.pop(context);
                  _confirmDelete(context, campaign);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showCampaignForm(BuildContext context, {Campaign? campaign}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _CampaignFormSheet(
            campaign: campaign,
            onSave: (savedCampaign) {
              if (campaign == null) {
                ref.read(campaignsProvider.notifier).addCampaign(savedCampaign);
              } else {
                ref.read(campaignsProvider.notifier).editCampaign(savedCampaign);
              }
              if (_selectedCampaign?.id == campaign?.id) {
                setState(() {
                  _selectedCampaign = savedCampaign;
                });
              }
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Campaign campaign) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Campanha'),
          content: Text('Tem certeza que deseja excluir "${campaign.name}"? Esta ação não pode ser desfeita.'),
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
                ref.read(campaignsProvider.notifier).removeCampaign(campaign.id!);
                if (_selectedCampaign?.id == campaign.id) {
                  setState(() {
                    _selectedCampaign = null;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTimeStr(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }
}

class _CampaignDetailView extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CampaignDetailView({
    required this.campaign,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(campaign.system),
                avatar: Icon(Icons.shield_rounded, size: 16, color: theme.colorScheme.secondary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
                    onPressed: onDelete,
                    tooltip: 'Excluir',
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            campaign.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Next Session Card
          Card(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próxima Sessão',
                          style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTimeStr(campaign.nextSession),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notas e Anotações',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: Text(
              campaign.notes.isEmpty ? 'Nenhuma nota registrada para esta mesa.' : campaign.notes,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTimeStr(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }
}

class _CampaignFormSheet extends StatefulWidget {
  final Campaign? campaign;
  final Function(Campaign) onSave;

  const _CampaignFormSheet({this.campaign, required this.onSave});

  @override
  State<_CampaignFormSheet> createState() => _CampaignFormSheetState();
}

class _CampaignFormSheetState extends State<_CampaignFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  String _selectedSystem = 'D&D 5e';
  late TextEditingController _customSystemController;
  late DateTime _selectedDateTime;

  final List<String> _systems = ['D&D 5e', 'Pathfinder 2e', 'Tormenta 20', 'Cthulhu', 'Outro'];

  @override
  void initState() {
    super.initState();
    final c = widget.campaign;
    _nameController = TextEditingController(text: c?.name ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _customSystemController = TextEditingController();

    if (c != null) {
      if (_systems.contains(c.system)) {
        _selectedSystem = c.system;
      } else {
        _selectedSystem = 'Outro';
        _customSystemController.text = c.system;
      }
      _selectedDateTime = DateTime.tryParse(c.nextSession) ?? DateTime.now();
    } else {
      _selectedDateTime = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _customSystemController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.campaign != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Editar Mesa / Campanha' : 'Criar Nova Mesa / Campanha',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campaign Name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome da Mesa / Aventura',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bookmark_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Por favor, insira o nome da aventura.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // System selection
            DropdownButtonFormField<String>(
              value: _selectedSystem,
              decoration: const InputDecoration(
                labelText: 'Sistema de Regras',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shield_rounded),
              ),
              items: _systems.map((sys) {
                return DropdownMenuItem(
                  value: sys,
                  child: Text(sys),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedSystem = val!;
                });
              },
            ),
            if (_selectedSystem == 'Outro') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customSystemController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do Sistema Customizado',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (_selectedSystem == 'Outro' && (val == null || val.trim().isEmpty)) {
                    return 'Insira o nome do sistema customizado.';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Date picker field
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data da Próxima Sessão',
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} às ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notas / Resumo / Agenda',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60.0),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final sysName =
                          _selectedSystem == 'Outro' ? _customSystemController.text.trim() : _selectedSystem;
                      final c = Campaign(
                        id: widget.campaign?.id,
                        name: _nameController.text.trim(),
                        system: sysName,
                        nextSession: _selectedDateTime.toIso8601String(),
                        notes: _notesController.text.trim(),
                      );
                      widget.onSave(c);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEdit ? 'Salvar Alterações' : 'Criar Campanha'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

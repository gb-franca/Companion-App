import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'encyclopedia_model.dart';
import 'encyclopedia_repository.dart';

class EncyclopediaState {
  final EncyclopediaType type;
  final String query;
  final AsyncValue<List<EncyclopediaItem>> results;

  EncyclopediaState({
    required this.type,
    required this.query,
    required this.results,
  });

  EncyclopediaState copyWith({
    EncyclopediaType? type,
    String? query,
    AsyncValue<List<EncyclopediaItem>>? results,
  }) {
    return EncyclopediaState(
      type: type ?? this.type,
      query: query ?? this.query,
      results: results ?? this.results,
    );
  }
}

class EncyclopediaNotifier extends Notifier<EncyclopediaState> {
  late final EncyclopediaRepository _repository;

  @override
  EncyclopediaState build() {
    _repository = ref.watch(encyclopediaRepositoryProvider);
    // Asynchronously trigger loading initial data on first frame
    Future.microtask(() => search());
    return EncyclopediaState(
      type: EncyclopediaType.spell,
      query: '',
      results: const AsyncValue<List<EncyclopediaItem>>.loading(),
    );
  }

  Future<void> setType(EncyclopediaType type) async {
    state = state.copyWith(type: type);
    await search();
  }

  Future<void> setQuery(String query) async {
    state = state.copyWith(query: query);
    await search();
  }

  Future<void> search() async {
    state = state.copyWith(results: const AsyncValue<List<EncyclopediaItem>>.loading());
    try {
      List<EncyclopediaItem> items;
      switch (state.type) {
        case EncyclopediaType.spell:
          items = await _repository.fetchSpells(query: state.query);
          break;
        case EncyclopediaType.creature:
          items = await _repository.fetchCreatures(query: state.query);
          break;
        case EncyclopediaType.item:
          items = await _repository.fetchItems(query: state.query);
          break;
      }
      state = state.copyWith(results: AsyncValue<List<EncyclopediaItem>>.data(items));
    } catch (e, stack) {
      state = state.copyWith(results: AsyncValue<List<EncyclopediaItem>>.error(e, stack));
    }
  }
}

final encyclopediaProvider = NotifierProvider<EncyclopediaNotifier, EncyclopediaState>(() {
  return EncyclopediaNotifier();
});

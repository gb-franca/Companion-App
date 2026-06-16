import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized');
});

class ThemeModeNotifier extends Notifier<bool> {
  static const _key = 'is_dark_mode';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? true;
  }

  void toggleTheme() {
    state = !state;
    ref.read(sharedPreferencesProvider).setBool(_key, state);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(() {
  return ThemeModeNotifier();
});

class FavoriteDiceNotifier extends Notifier<List<String>> {
  static const _key = 'favorite_dice';

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_key) ?? ['d20', 'd6'];
  }

  void toggleFavorite(String die) {
    final prefs = ref.read(sharedPreferencesProvider);
    final current = List<String>.from(state);
    if (current.contains(die)) {
      current.remove(die);
    } else {
      current.add(die);
    }
    state = current;
    prefs.setStringList(_key, current);
  }

  bool isFavorite(String die) {
    return state.contains(die);
  }
}

final favoriteDiceProvider = NotifierProvider<FavoriteDiceNotifier, List<String>>(() {
  return FavoriteDiceNotifier();
});

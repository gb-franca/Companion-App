import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import 'encyclopedia_model.dart';

final encyclopediaRepositoryProvider = Provider<EncyclopediaRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return EncyclopediaRepository(dio);
});

class EncyclopediaRepository {
  final Dio _dio;

  EncyclopediaRepository(this._dio);

  Future<List<EncyclopediaItem>> fetchSpells({String? query}) async {
    final Map<String, dynamic> queryParams = {
      'limit': 20,
    };
    if (query != null && query.isNotEmpty) {
      queryParams['name__icontains'] = query;
    }
    final response = await _dio.get('spells/', queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => EncyclopediaItem.fromSpellJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EncyclopediaItem>> fetchCreatures({String? query}) async {
    final Map<String, dynamic> queryParams = {
      'limit': 20,
    };
    if (query != null && query.isNotEmpty) {
      queryParams['name__icontains'] = query;
    }
    final response = await _dio.get('creatures/', queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => EncyclopediaItem.fromCreatureJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EncyclopediaItem>> fetchItems({String? query}) async {
    final Map<String, dynamic> queryParams = {
      'limit': 20,
    };
    if (query != null && query.isNotEmpty) {
      queryParams['name__icontains'] = query;
    }
    final response = await _dio.get('magicitems/', queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => EncyclopediaItem.fromItemJson(e as Map<String, dynamic>)).toList();
  }
}

import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:companion_app/features/encyclopedia/encyclopedia_repository.dart';
import 'package:companion_app/features/encyclopedia/encyclopedia_model.dart';

// Import the generated mocks
import 'encyclopedia_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late EncyclopediaRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = EncyclopediaRepository(mockDio);
  });

  group('EncyclopediaRepository Tests', () {
    test('fetchSpells returns list of spells on success', () async {
      // Arrange
      final responseData = {
        'results': [
          {
            'name': 'Fireball',
            'desc': 'A bright streak flashes from your pointing finger...',
            'level': 3,
            'school': {'name': 'Evocation'},
            'casting_time': '1 action',
            'range': '150 feet',
            'components': 'V, S, M',
            'duration': 'Instantaneous',
            'concentration': false,
            'ritual': false
          }
        ]
      };

      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await repository.fetchSpells(query: 'Fireball');

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.name, equals('Fireball'));
      expect(result.first.type, equals(EncyclopediaType.spell));
      expect(result.first.subtitle, equals('Nível 3 • Evocation'));
      expect(result.first.details['casting_time'], equals('1 action'));
    });

    test('fetchSpells throws exception on network failure', () async {
      // Arrange
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act & Assert
      expect(
        () => repository.fetchSpells(query: 'Fireball'),
        throwsA(isA<DioException>()),
      );
    });

    test('fetchCreatures returns list of creatures on success', () async {
      // Arrange
      final responseData = {
        'results': [
          {
            'name': 'Goblin',
            'desc': 'Goblins are small, black-hearted humanoid...',
            'size': 'Small',
            'type': 'humanoid',
            'alignment': 'neutral evil',
            'armor_class': 15,
            'armor_desc': 'leather armor, shield',
            'hit_points': 7,
            'hit_dice': '2d6',
            'speed': '30 ft.',
            'languages': 'Common, Goblin',
            'strength': 8,
            'dexterity': 14,
            'constitution': 10,
            'intelligence': 10,
            'wisdom': 8,
            'charisma': 8
          }
        ]
      };

      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await repository.fetchCreatures(query: 'Goblin');

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.name, equals('Goblin'));
      expect(result.first.type, equals(EncyclopediaType.creature));
      expect(result.first.subtitle, contains('Small humanoid'));
      expect(result.first.details['armor_class'], equals(15));
    });

    test('fetchItems returns list of items on success', () async {
      // Arrange
      final responseData = {
        'results': [
          {
            'name': 'Bag of Holding',
            'desc': 'This bag has an interior space considerably larger...',
            'category': 'Wondrous Item',
            'rarity': 'Uncommon',
            'weight': 15.0,
            'weight_unit': 'lbs',
            'requires_attunement': false
          }
        ]
      };

      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await repository.fetchItems(query: 'Bag');

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.name, equals('Bag of Holding'));
      expect(result.first.type, equals(EncyclopediaType.item));
      expect(result.first.subtitle, contains('Wondrous Item • Uncommon'));
      expect(result.first.details['weight'], equals('15.0 lbs'));
    });

    group('Mocking Query Parameters', () {
      test('fetches correct path and appends icontains parameter', () async {
        // Arrange
        final responseData = {
          'results': <Map<String, dynamic>>[]
        };

        when(mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        await repository.fetchSpells(query: 'healing');

        // Assert
        verify(mockDio.get<Map<String, dynamic>>(
          'spells/',
          queryParameters: {'limit': 20, 'name__icontains': 'healing'},
        )).called(1);
      });
    });
  });
}

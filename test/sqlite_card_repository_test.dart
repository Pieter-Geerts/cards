import 'package:cards/helpers/i_database_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/repositories/sqlite_card_repository.dart';
import 'package:cards/services/error_handling_service.dart';
import 'package:cards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sqlite_card_repository_test.mocks.dart';

class _TestDatabaseException implements Exception {
  final String message;
  _TestDatabaseException(this.message);
}

@GenerateMocks([IDatabaseHelper, ErrorHandlingService])
void main() {
  late MockIDatabaseHelper mockDbHelper;
  late MockErrorHandlingService mockErrorHandlingService;
  late SqliteCardRepository repository;

  setUp(() {
    mockDbHelper = MockIDatabaseHelper();
    mockErrorHandlingService = MockErrorHandlingService();
    repository = SqliteCardRepository(
      dbHelper: mockDbHelper,
      errorHandlingService: mockErrorHandlingService,
    );
  });

  group('SqliteCardRepository', () {
    final tCard = CardItem(
      id: 1,
      title: 'Test',
      description: 'Test desc',
      name: '1234',
      cardType: CardType.qrCode,
      sortOrder: 0,
    );

    test('getCards returns Right(List<CardItem>) on success', () async {
      when(mockDbHelper.getCards()).thenAnswer((_) async => [tCard]);

      final result = await repository.getCards();

      expect(result, isA<Right>());
      result.fold((l) => fail('should be Right'), (r) => expect(r, [tCard]));
      verify(mockDbHelper.getCards());
      verifyNoMoreInteractions(mockDbHelper);
      verifyZeroInteractions(mockErrorHandlingService);
    });

    test('getCards returns Left(Failure) on database exception', () async {
      final exception = _TestDatabaseException('DB error');
      when(mockDbHelper.getCards()).thenThrow(exception);

      final result = await repository.getCards();

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l, isA<Failure>());
        expect(l.message, 'Failed to load cards.');
        expect(l.exception, exception);
      }, (r) => fail('should be Left'));
      verify(mockDbHelper.getCards());
      verify(
        mockErrorHandlingService.handleError(
          exception,
          any,
          context: 'getCards',
        ),
      );
      verifyNoMoreInteractions(mockDbHelper);
    });

    test('insertCard returns Right(id) on success', () async {
      when(mockDbHelper.insertCard(any)).thenAnswer((_) async => 1);

      final result = await repository.insertCard(tCard);

      expect(result, isA<Right>());
      result.fold((l) => fail('should be Right'), (r) => expect(r, 1));
      verify(mockDbHelper.insertCard(tCard));
      verifyNoMoreInteractions(mockDbHelper);
    });

    test('insertCard returns Left(Failure) on database exception', () async {
      final exception = _TestDatabaseException('DB error');
      when(mockDbHelper.insertCard(any)).thenThrow(exception);

      final result = await repository.insertCard(tCard);

      expect(result, isA<Left>());
      result.fold((l) {
        expect(l.message, 'Failed to save card. Please try again.');
        expect(l.exception, exception);
      }, (r) => fail('should be Left'));
      verify(mockDbHelper.insertCard(tCard));
      verify(
        mockErrorHandlingService.handleError(
          exception,
          any,
          context: 'insertCard',
        ),
      );
    });
  });
}

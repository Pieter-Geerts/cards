import 'package:cards/models/card_item.dart';
import 'package:cards/repositories/card_repository_factory.dart';
import 'package:cards/repositories/cloud_card_repository.dart';
import 'package:cards/repositories/sqlite_card_repository.dart';
import 'package:cards/utils/result.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCloudDataSource implements CloudCardDataSource {
  CardItem? inserted;

  @override
  Future<Either<Failure, int>> insertCard(CardItem card) async {
    inserted = card;
    return const Right(42);
  }

  @override
  Future<Either<Failure, List<CardItem>>> getCards() async => const Right([]);

  @override
  Future<Either<Failure, int>> getNextSortOrder() async => const Right(0);

  @override
  Future<Either<Failure, void>> updateCardSortOrders(
    List<CardItem> cards,
  ) async => const Right(null);

  @override
  Future<Either<Failure, int>> deleteCard(int id) async => const Right(1);

  @override
  Future<Either<Failure, int>> updateCard(CardItem card) async =>
      const Right(1);

  @override
  Future<Either<Failure, void>> deleteAllCards() async => const Right(null);

  @override
  Future<Either<Failure, CardItem?>> getCard(int id) async => const Right(null);

  @override
  Future<Either<Failure, int>> backfillLogoPathsFromTitles({
    bool dryRun = true,
  }) async => const Right(0);
}

void main() {
  test(
    'cloud repository delegates through the shared repository contract',
    () async {
      final source = _FakeCloudDataSource();
      final repository = CloudCardRepository(dataSource: source);
      final card = CardItem(
        title: 'Remote card',
        description: '',
        name: 'remote-code',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      final result = await repository.insertCard(card);

      expect(result, const Right<Failure, int>(42));
      expect(source.inserted, card);
    },
  );

  test(
    'factory creates local repositories without exposing the concrete type to callers',
    () {
      final repository = CardRepositoryFactory.create();

      expect(repository, isA<SqliteCardRepository>());
    },
  );

  test('factory requires a data source for cloud repositories', () {
    expect(
      () => CardRepositoryFactory.create(backend: CardRepositoryBackend.cloud),
      throwsArgumentError,
    );
  });
}

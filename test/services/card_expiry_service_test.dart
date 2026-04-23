import 'package:cards/models/card_item.dart';
import 'package:cards/repositories/card_repository_interface.dart';
import 'package:cards/services/card_expiry_service.dart';
import 'package:cards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'card_expiry_service_test.mocks.dart';

@GenerateMocks([CardRepository])
void main() {
  late MockCardRepository mockCardRepository;
  late CardExpiryService expiryService;

  setUpAll(() {
    // Provide dummy builders for Either types used by Mockito
    provideDummy<Either<Failure, List<CardItem>>>(Right(<CardItem>[]));
    provideDummy<Either<Failure, int>>(const Right(0));
  });

  setUp(() {
    mockCardRepository = MockCardRepository();
    expiryService = CardExpiryService(cardRepository: mockCardRepository);
  });

  group('CardExpiryService - deleteExpiredCards', () {
    test('should delete 0 cards when none are expired', () async {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 10));

      final cards = [
        CardItem(
          id: 1,
          title: 'Valid Card 1',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 0,
          expiresAt: future,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card 2',
          description: 'Not expired',
          name: 'VALID2',
          sortOrder: 1,
          expiresAt: future,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 0),
      );
      verify(mockCardRepository.getCards());
      verifyNoMoreInteractions(mockCardRepository);
    });

    test('should delete all expired cards', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card 1',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Expired Card 2',
          description: 'Expired',
          name: 'EXP2',
          sortOrder: 1,
          expiresAt: yesterday,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));
      when(
        mockCardRepository.deleteCard(1),
      ).thenAnswer((_) async => const Right(1));
      when(
        mockCardRepository.deleteCard(2),
      ).thenAnswer((_) async => const Right(1));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 2),
      );
      verify(mockCardRepository.getCards());
      verify(mockCardRepository.deleteCard(1));
      verify(mockCardRepository.deleteCard(2));
    });

    test('should delete only expired cards, leaving valid ones', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 1,
          expiresAt: tomorrow,
        ),
        CardItem(
          id: 3,
          title: 'Permanent Card',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 2,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));
      when(
        mockCardRepository.deleteCard(1),
      ).thenAnswer((_) async => const Right(1));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 1),
      );
      verify(mockCardRepository.getCards());
      verify(mockCardRepository.deleteCard(1));
      verifyNever(mockCardRepository.deleteCard(2));
      verifyNever(mockCardRepository.deleteCard(3));
    });

    test('should use reference time correctly', () async {
      final referenceTime = DateTime(2024, 6, 15, 12, 0, 0);
      final expiryDate = DateTime(2024, 6, 15, 0, 0, 0);

      final cards = [
        CardItem(
          id: 1,
          title: 'Card Expiring Today',
          description: 'Same day expiry',
          name: 'TODAY1',
          sortOrder: 0,
          expiresAt: expiryDate,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));
      when(
        mockCardRepository.deleteCard(1),
      ).thenAnswer((_) async => const Right(1));

      final result = await expiryService.deleteExpiredCards(referenceTime);

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 1),
      );
      verify(mockCardRepository.deleteCard(1));
    });

    test('should return Left(Failure) when getCards fails', () async {
      final failure = Failure(
        'Database error',
        exception: Exception('DB Error'),
      );

      when(
        mockCardRepository.getCards(),
      ).thenAnswer((_) async => Left(failure));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Left>());
      result.fold(
        (f) => expect(f.message, 'Database error'),
        (count) => fail('Should be Left'),
      );
    });

    test('should continue deleting even if one delete fails', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card 1',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Expired Card 2',
          description: 'Expired',
          name: 'EXP2',
          sortOrder: 1,
          expiresAt: yesterday,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));
      when(mockCardRepository.deleteCard(1)).thenAnswer(
        (_) async => Left(Failure('Failed to delete', exception: Exception())),
      );
      when(
        mockCardRepository.deleteCard(2),
      ).thenAnswer((_) async => const Right(1));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 1), // Only card 2 was successfully deleted
      );
      verify(mockCardRepository.deleteCard(1));
      verify(mockCardRepository.deleteCard(2));
    });

    test('should skip cards with no ID', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final cards = [
        CardItem(
          id: null, // No ID
          title: 'Temp Expired Card',
          description: 'Expired but no ID',
          name: 'TEMP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 0),
      );
      verifyNever(mockCardRepository.deleteCard(any));
    });

    test('should return 0 when all cards are permanent (no expiry)', () async {
      final cards = [
        CardItem(
          id: 1,
          title: 'Permanent Card 1',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 0,
        ),
        CardItem(
          id: 2,
          title: 'Permanent Card 2',
          description: 'No expiry',
          name: 'PERM2',
          sortOrder: 1,
        ),
      ];

      when(mockCardRepository.getCards()).thenAnswer((_) async => Right(cards));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 0),
      );
      verifyNever(mockCardRepository.deleteCard(any));
    });

    test('should return 0 when repository returns empty list', () async {
      when(
        mockCardRepository.getCards(),
      ).thenAnswer((_) async => const Right([]));

      final result = await expiryService.deleteExpiredCards();

      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should be Right'),
        (count) => expect(count, 0),
      );
      verifyNever(mockCardRepository.deleteCard(any));
    });
  });

  group('CardExpiryService - getExpiredCards', () {
    test('should return empty list when no cards are expired', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 5));

      final cards = [
        CardItem(
          id: 1,
          title: 'Valid Card',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 0,
          expiresAt: future,
        ),
      ];

      final result = expiryService.getExpiredCards(cards);

      expect(result, isEmpty);
    });

    test('should return all expired cards', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card 1',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Expired Card 2',
          description: 'Expired',
          name: 'EXP2',
          sortOrder: 1,
          expiresAt: yesterday,
        ),
      ];

      final result = expiryService.getExpiredCards(cards);

      expect(result, hasLength(2));
      expect(result.map((c) => c.id), containsAll([1, 2]));
    });

    test('should filter expired from mixed list', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 1,
          expiresAt: tomorrow,
        ),
        CardItem(
          id: 3,
          title: 'Permanent Card',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 2,
        ),
      ];

      final result = expiryService.getExpiredCards(cards);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
    });

    test('should respect reference time parameter', () {
      final referenceTime = DateTime(2024, 6, 15, 12, 0, 0);
      final expiryDate = DateTime(2024, 6, 15, 0, 0, 0);

      final cards = [
        CardItem(
          id: 1,
          title: 'Card Expiring Today',
          description: 'Same day expiry',
          name: 'TODAY1',
          sortOrder: 0,
          expiresAt: expiryDate,
        ),
      ];

      final result = expiryService.getExpiredCards(cards, referenceTime);

      expect(result, hasLength(1));
    });
  });

  group('CardExpiryService - getValidCards', () {
    test('should return all valid cards', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 5));

      final cards = [
        CardItem(
          id: 1,
          title: 'Valid Card 1',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 0,
          expiresAt: future,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card 2',
          description: 'Not expired',
          name: 'VALID2',
          sortOrder: 1,
          expiresAt: future,
        ),
        CardItem(
          id: 3,
          title: 'Permanent Card',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 2,
        ),
      ];

      final result = expiryService.getValidCards(cards);

      expect(result, hasLength(3));
    });

    test('should filter out expired cards', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 1,
          expiresAt: tomorrow,
        ),
        CardItem(
          id: 3,
          title: 'Permanent Card',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 2,
        ),
      ];

      final result = expiryService.getValidCards(cards);

      expect(result, hasLength(2));
      expect(result.map((c) => c.id), containsAll([2, 3]));
    });

    test('should return empty list when all cards are expired', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card 1',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Expired Card 2',
          description: 'Expired',
          name: 'EXP2',
          sortOrder: 1,
          expiresAt: yesterday,
        ),
      ];

      final result = expiryService.getValidCards(cards);

      expect(result, isEmpty);
    });
  });

  group('CardExpiryService - count methods', () {
    test('getExpiredCardCount should return correct count', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card 1',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Expired Card 2',
          description: 'Expired',
          name: 'EXP2',
          sortOrder: 1,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 3,
          title: 'Valid Card',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 2,
          expiresAt: tomorrow,
        ),
      ];

      final count = expiryService.getExpiredCardCount(cards);

      expect(count, 2);
    });

    test('getValidCardCount should return correct count', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card 1',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 1,
          expiresAt: tomorrow,
        ),
        CardItem(
          id: 3,
          title: 'Valid Card 2',
          description: 'Not expired',
          name: 'VALID2',
          sortOrder: 2,
          expiresAt: tomorrow,
        ),
        CardItem(
          id: 4,
          title: 'Permanent Card',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 3,
        ),
      ];

      final count = expiryService.getValidCardCount(cards);

      expect(count, 3);
    });

    test('counts should sum to total card count', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Expired Card',
          description: 'Expired',
          name: 'EXP1',
          sortOrder: 0,
          expiresAt: yesterday,
        ),
        CardItem(
          id: 2,
          title: 'Valid Card',
          description: 'Not expired',
          name: 'VALID1',
          sortOrder: 1,
          expiresAt: tomorrow,
        ),
        CardItem(
          id: 3,
          title: 'Permanent Card',
          description: 'No expiry',
          name: 'PERM1',
          sortOrder: 2,
        ),
      ];

      final expiredCount = expiryService.getExpiredCardCount(cards);
      final validCount = expiryService.getValidCardCount(cards);

      expect(expiredCount + validCount, cards.length);
    });
  });

  group('CardExpiryService - edge cases', () {
    test('should handle cards expiring at exact midnight', () {
      final midnight = DateTime(2024, 6, 16, 0, 0, 0);
      final oneSecondBefore = midnight.subtract(const Duration(seconds: 1));

      final cards = [
        CardItem(
          id: 1,
          title: 'Midnight Card',
          description: 'Expires at midnight',
          name: 'MIDNIGHT1',
          sortOrder: 0,
          expiresAt: midnight,
        ),
      ];

      // One second before midnight - not expired
      final resultBefore = expiryService.getExpiredCards(
        cards,
        oneSecondBefore,
      );
      expect(resultBefore, isEmpty);

      // At midnight - expired
      final resultAt = expiryService.getExpiredCards(cards, midnight);
      expect(resultAt, hasLength(1));
    });

    test('should handle very old expiry dates', () {
      final veryOld = DateTime(2000, 1, 1);

      final cards = [
        CardItem(
          id: 1,
          title: 'Very Old Card',
          description: 'Expired long ago',
          name: 'OLD1',
          sortOrder: 0,
          expiresAt: veryOld,
        ),
      ];

      final result = expiryService.getExpiredCards(cards);

      expect(result, hasLength(1));
    });

    test('should handle very far future expiry dates', () {
      final veryFar = DateTime(2100, 12, 31);

      final cards = [
        CardItem(
          id: 1,
          title: 'Future Card',
          description: 'Expires far in future',
          name: 'FUTURE1',
          sortOrder: 0,
          expiresAt: veryFar,
        ),
      ];

      final result = expiryService.getExpiredCards(cards);

      expect(result, isEmpty);
    });
  });
}

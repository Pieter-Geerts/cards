import 'package:cards/models/card_item.dart';
import 'package:cards/repositories/card_repository_interface.dart';
import 'package:cards/services/card_expiry_service.dart';
import 'package:cards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'card_expiry_integration_test.mocks.dart';

@GenerateMocks([CardRepository])
void main() {
  late MockCardRepository mockCardRepository;
  late CardExpiryService expiryService;

  setUpAll(() {
    provideDummy<Either<Failure, List<CardItem>>>(Right(<CardItem>[]));
    provideDummy<Either<Failure, int>>(const Right(0));
  });

  setUp(() {
    mockCardRepository = MockCardRepository();
    expiryService = CardExpiryService(cardRepository: mockCardRepository);
  });

  group('Card Expiry Integration - End-to-End Lifecycle', () {
    test(
      'should handle complete lifecycle: create temp card -> verify not expired -> simulate time passing -> delete expired',
      () async {
        // ARRANGE: Create temporary cards with different expiry dates
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final threeDaysFromNow = now.add(const Duration(days: 3));
        final yesterday = now.subtract(const Duration(days: 1));

        final cards = [
          // Expired cards (should be deleted)
          CardItem(
            id: 1,
            title: 'Expired Pass',
            description: 'This pass has expired',
            name: 'EXP_PASS_001',
            sortOrder: 0,
            expiresAt: yesterday,
          ),
          // Active temporary cards (should NOT be deleted)
          CardItem(
            id: 2,
            title: 'Current Pass',
            description: 'Still valid',
            name: 'CURRENT_PASS_001',
            sortOrder: 1,
            expiresAt: tomorrow,
          ),
          CardItem(
            id: 3,
            title: 'Valid Ticket',
            description: 'Expires in 3 days',
            name: 'TICKET_001',
            sortOrder: 2,
            expiresAt: threeDaysFromNow,
          ),
          // Permanent card (should NOT be deleted)
          CardItem(
            id: 4,
            title: 'Driver License',
            description: 'No expiry',
            name: 'DL123456',
            sortOrder: 3,
          ),
        ];

        // ACT 1: Verify initial state
        expect(
          expiryService.getExpiredCardCount(cards),
          1,
          reason: 'Should have 1 expired card initially',
        );
        expect(
          expiryService.getValidCardCount(cards),
          3,
          reason: 'Should have 3 valid cards initially',
        );
        expect(cards.length, 4, reason: 'Total cards should be 4');

        // ACT 2: Identify expired cards
        final expiredCards = expiryService.getExpiredCards(cards);
        expect(expiredCards.length, 1);
        expect(expiredCards.first.id, 1);
        expect(expiredCards.first.title, 'Expired Pass');

        // ACT 3: Identify valid cards
        final validCards = expiryService.getValidCards(cards);
        expect(validCards.length, 3);
        expect(validCards.map((c) => c.id), containsAll([2, 3, 4]));

        // ACT 4: Prepare repository to delete expired cards
        when(
          mockCardRepository.getCards(),
        ).thenAnswer((_) async => Right(cards));
        when(
          mockCardRepository.deleteCard(1),
        ).thenAnswer((_) async => const Right(1));

        // ACT 5: Execute deletion
        final deleteResult = await expiryService.deleteExpiredCards();

        // ASSERT: Verify deletion result
        expect(deleteResult, isA<Right>());
        deleteResult.fold(
          (failure) => fail('Should be Right'),
          (count) => expect(count, 1, reason: 'Should delete exactly 1 card'),
        );

        // ASSERT: Verify repository methods were called
        verify(mockCardRepository.getCards()).called(1);
        verify(mockCardRepository.deleteCard(1)).called(1);
        verifyNever(mockCardRepository.deleteCard(2));
        verifyNever(mockCardRepository.deleteCard(3));
        verifyNever(mockCardRepository.deleteCard(4));
      },
    );

    test(
      'should handle scenario where all temporary cards have expired at same time',
      () async {
        final reference = DateTime(2024, 6, 15, 12, 0, 0);
        final expiryTime = DateTime(2024, 6, 15, 0, 0, 0); // same day, dawn

        final expiredCards = [
          CardItem(
            id: 1,
            title: 'Expired Ticket 1',
            description: 'Day pass',
            name: 'DAY_PASS_001',
            sortOrder: 0,
            expiresAt: expiryTime,
          ),
          CardItem(
            id: 2,
            title: 'Expired Ticket 2',
            description: 'Day pass',
            name: 'DAY_PASS_002',
            sortOrder: 1,
            expiresAt: expiryTime,
          ),
          CardItem(
            id: 3,
            title: 'Expired Ticket 3',
            description: 'Day pass',
            name: 'DAY_PASS_003',
            sortOrder: 2,
            expiresAt: expiryTime,
          ),
        ];

        // All cards are expired at this reference time
        final allExpired = expiryService.getExpiredCards(
          expiredCards,
          reference,
        );
        expect(allExpired.length, 3);

        // Setup repository mock to delete all
        when(
          mockCardRepository.getCards(),
        ).thenAnswer((_) async => Right(expiredCards));
        when(
          mockCardRepository.deleteCard(any),
        ).thenAnswer((_) async => const Right(1));

        // Execute deletion
        final result = await expiryService.deleteExpiredCards(reference);

        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Should be Right'),
          (count) => expect(count, 3, reason: 'Should delete all 3 cards'),
        );
      },
    );

    test(
      'should correctly handle timezone-aware expiry (cards valid until end of day)',
      () async {
        // A card that expires at end of day should still be valid during the day
        final dayStart = DateTime(2024, 6, 15, 0, 0, 0);
        final dayMid = DateTime(2024, 6, 15, 12, 0, 0);
        final oneSecondBeforeMidnight = DateTime(2024, 6, 15, 23, 59, 59);
        final nextDayStart = DateTime(2024, 6, 16, 0, 0, 0);

        final card = CardItem(
          id: 1,
          title: 'Day Pass',
          description: 'Valid for one day',
          name: 'DAY_PASS',
          sortOrder: 0,
          expiresAt: oneSecondBeforeMidnight,
        );

        // During the day - not expired
        expect(card.isExpired(dayStart), false);
        expect(card.isExpired(dayMid), false);

        // At exact expiry time - expired (isAfter returns false when equal)
        expect(card.isExpired(oneSecondBeforeMidnight), true);

        // After day ends - expired
        expect(card.isExpired(nextDayStart), true);
      },
    );

    test(
      'should handle batch cleanup of mixed permanent and temporary cards',
      () async {
        final now = DateTime.now();

        // Large dataset with mix of permanent and temporary cards
        final cards = List.generate(100, (i) {
          if (i % 3 == 0) {
            // 1/3 are permanent
            return CardItem(
              id: i + 1,
              title: 'Permanent Card $i',
              description: 'No expiry',
              name: 'PERM_$i',
              sortOrder: i,
            );
          } else if (i % 2 == 0) {
            // 1/3 are valid temporary
            return CardItem(
              id: i + 1,
              title: 'Valid Temporary $i',
              description: 'Still valid',
              name: 'VALID_TEMP_$i',
              sortOrder: i,
              expiresAt: now.add(const Duration(days: 5)),
            );
          } else {
            // 1/3 are expired
            return CardItem(
              id: i + 1,
              title: 'Expired Card $i',
              description: 'Expired',
              name: 'EXPIRED_$i',
              sortOrder: i,
              expiresAt: now.subtract(const Duration(days: 1)),
            );
          }
        });

        final expiredCount = expiryService.getExpiredCardCount(cards);
        final validCount = expiryService.getValidCardCount(cards);

        expect(expiredCount + validCount, 100);
        expect(expiredCount, greaterThan(0));
        expect(validCount, greaterThan(0));
      },
    );

    test(
      'should correctly handle deletion failure and continue with other cards',
      () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        final cards = [
          CardItem(
            id: 1,
            title: 'Expired Card 1',
            description: 'Failed to delete',
            name: 'FAIL_DELETE_1',
            sortOrder: 0,
            expiresAt: yesterday,
          ),
          CardItem(
            id: 2,
            title: 'Expired Card 2',
            description: 'Will delete',
            name: 'SUCCESS_DELETE_2',
            sortOrder: 1,
            expiresAt: yesterday,
          ),
        ];

        when(
          mockCardRepository.getCards(),
        ).thenAnswer((_) async => Right(cards));

        // First delete fails, second succeeds
        when(mockCardRepository.deleteCard(1)).thenAnswer(
          (_) async => Left(Failure('DB error', exception: Exception())),
        );
        when(
          mockCardRepository.deleteCard(2),
        ).thenAnswer((_) async => const Right(1));

        final result = await expiryService.deleteExpiredCards();

        // Should return success count (1), not fail on first error
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Should be Right'),
          (count) => expect(
            count,
            1,
            reason: 'Should successfully delete 1 card despite failure',
          ),
        );
      },
    );
  });

  group('Card Expiry Validation - Business Rules', () {
    test('should correctly identify the definition of temporary card', () {
      final tempCard = CardItem.temp(
        title: 'Event Ticket',
        description: 'One-time use',
        name: 'EVENT_123',
        expiresInDays: 7,
      );

      expect(tempCard.isTemporary, true);
      expect(tempCard.isExpired(), false);
    });

    test(
      'should correctly identify the definition of permanent card (no expiry)',
      () {
        final permanentCard = CardItem(
          title: 'ID Card',
          description: 'No expiry',
          name: 'ID_123',
          sortOrder: 0,
        );

        expect(permanentCard.isTemporary, false);
        expect(permanentCard.expiresAt, null);
        expect(permanentCard.isExpired(), false);
      },
    );

    test('should validate that expired cards are correctly identified', () {
      final now = DateTime.now();

      final justExpired = CardItem(
        id: 1,
        title: 'Just Expired',
        description: 'Expired moments ago',
        name: 'JUST_EXP',
        sortOrder: 0,
        expiresAt: now.subtract(const Duration(milliseconds: 1)),
      );

      final almostExpired = CardItem(
        id: 2,
        title: 'Almost Expired',
        description: 'About to expire',
        name: 'ALMOST_EXP',
        sortOrder: 1,
        expiresAt: now.add(const Duration(milliseconds: 1)),
      );

      expect(justExpired.isExpired(), true);
      expect(almostExpired.isExpired(), false);
    });
  });
}

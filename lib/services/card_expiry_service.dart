import 'package:fpdart/fpdart.dart';

import '../models/card_item.dart';
import '../repositories/card_repository_interface.dart';
import '../utils/result.dart';

/// Service responsible for managing card expiration and cleanup of expired cards.
///
/// This service provides functionality to:
/// - Delete expired cards from the repository
/// - Filter expired cards from a list
/// - Check expiry status of cards
class CardExpiryService {
  final CardRepository _cardRepository;

  CardExpiryService({required CardRepository cardRepository})
    : _cardRepository = cardRepository;

  /// Retrieves all cards and deletes those that have expired.
  ///
  /// Returns a [Right] with the number of cards deleted, or a [Left] with
  /// a [Failure] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// final result = await expiryService.deleteExpiredCards();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (count) => print('Deleted $count expired cards'),
  /// );
  /// ```
  Future<Either<Failure, int>> deleteExpiredCards([DateTime? asOf]) async {
    try {
      // Get all cards from repository
      final cardsResult = await _cardRepository.getCards();

      return cardsResult.fold((failure) => Left(failure), (cards) async {
        // Filter expired cards
        final expiredCards = _getExpiredCards(cards, asOf);

        if (expiredCards.isEmpty) {
          return const Right(0);
        }

        // Delete each expired card
        int deletedCount = 0;
        for (final card in expiredCards) {
          if (card.id != null) {
            final deleteResult = await _cardRepository.deleteCard(card.id!);
            deleteResult.fold(
              (failure) => null, // Continue deleting other cards
              (count) => deletedCount += count,
            );
          }
        }

        return Right(deletedCount);
      });
    } catch (e) {
      return Left(Failure('Failed to delete expired cards', exception: e));
    }
  }

  /// Filters and returns only the expired cards from a given list.
  ///
  /// Parameters:
  /// - [cards]: The list of cards to filter
  /// - [asOf]: Optional reference time for expiry check (defaults to now)
  ///
  /// Returns a list of expired cards.
  List<CardItem> getExpiredCards(List<CardItem> cards, [DateTime? asOf]) {
    return _getExpiredCards(cards, asOf);
  }

  /// Filters and returns only the non-expired cards from a given list.
  ///
  /// Parameters:
  /// - [cards]: The list of cards to filter
  /// - [asOf]: Optional reference time for expiry check (defaults to now)
  ///
  /// Returns a list of non-expired cards.
  List<CardItem> getValidCards(List<CardItem> cards, [DateTime? asOf]) {
    return cards.where((card) => !card.isExpired(asOf)).toList();
  }

  /// Gets the count of expired cards in a list.
  int getExpiredCardCount(List<CardItem> cards, [DateTime? asOf]) {
    return _getExpiredCards(cards, asOf).length;
  }

  /// Gets the count of valid (non-expired) cards in a list.
  int getValidCardCount(List<CardItem> cards, [DateTime? asOf]) {
    return cards.where((card) => !card.isExpired(asOf)).length;
  }

  /// Internal helper to get expired cards
  List<CardItem> _getExpiredCards(List<CardItem> cards, [DateTime? asOf]) {
    return cards.where((card) => card.isExpired(asOf)).toList();
  }
}

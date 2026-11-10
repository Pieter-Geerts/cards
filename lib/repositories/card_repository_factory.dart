import '../helpers/i_database_helper.dart';
import '../services/error_handling_service.dart';
import 'card_repository_interface.dart';
import 'cloud_card_repository.dart';
import 'sqlite_card_repository.dart';

enum CardRepositoryBackend { local, cloud }

/// Constructs repositories without coupling callers to a storage provider.
class CardRepositoryFactory {
  const CardRepositoryFactory._();

  static CardRepository create({
    CardRepositoryBackend backend = CardRepositoryBackend.local,
    IDatabaseHelper? dbHelper,
    ErrorHandlingService? errorHandlingService,
    CloudCardDataSource? cloudDataSource,
  }) {
    switch (backend) {
      case CardRepositoryBackend.local:
        return SqliteCardRepository(
          dbHelper: dbHelper,
          errorHandlingService: errorHandlingService,
        );
      case CardRepositoryBackend.cloud:
        final dataSource = cloudDataSource;
        if (dataSource == null) {
          throw ArgumentError.value(
            cloudDataSource,
            'cloudDataSource',
            'A cloud data source is required for the cloud backend.',
          );
        }
        return CloudCardRepository(dataSource: dataSource);
    }
  }
}

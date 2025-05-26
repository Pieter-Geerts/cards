// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cards - QR Scanner';

  @override
  String get myCards => 'My Cards';

  @override
  String get addCard => 'Add Card';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get noCardsYet => 'No cards yet. Add your first card!';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this card?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String cardType(Object type) {
    return 'Type: $type';
  }

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'Enter a title for this card';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Enter a description';

  @override
  String get barcode => 'Barcode';

  @override
  String get qrCode => 'QR Code';

  @override
  String get barcodeValue => 'Barcode Value';

  @override
  String get qrCodeValue => 'QR Code Value';

  @override
  String get enterBarcodeValue => 'Enter the barcode value';

  @override
  String get enterQrCodeValue => 'Enter the QR code value';

  @override
  String detectedFormat(Object format) {
    return 'Detected: $format';
  }

  @override
  String get noDataScanned => 'No data scanned';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get dutch => 'Dutch';

  @override
  String get theme => 'Theme';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String scanSuccessMessage(Object format) {
    return '$format detected successfully!';
  }

  @override
  String get validationPleaseEnterValue => 'Please enter a value';

  @override
  String get validationBarcodeOnlyAlphanumeric =>
      'Barcode can only contain numbers and letters';

  @override
  String get validationBarcodeMinLength =>
      'Barcode should be at least 3 characters';

  @override
  String get validationTitleRequired => 'Please enter a title';

  @override
  String get validationTitleMinLength =>
      'Title should be at least 3 characters';

  @override
  String get validationDescriptionMinLength =>
      'Description should be at least 5 characters';

  @override
  String get textBarcode => 'Barcode';

  @override
  String get textQrCode => 'QR Code';

  @override
  String get search => 'Search';

  @override
  String get noResultsFound => 'No results found for';

  @override
  String get editCard => 'Edit Card';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get shareAsImage => 'Share as Image';
}

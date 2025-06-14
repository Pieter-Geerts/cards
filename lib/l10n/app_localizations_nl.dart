// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Kaarten - QR Scanner';

  @override
  String get myCards => 'Mijn Kaarten';

  @override
  String get addCard => 'Kaart Toevoegen';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get manualEntry => 'Handmatige Invoer';

  @override
  String get noCardsYet => 'Nog geen kaarten. Voeg je eerste kaart toe!';

  @override
  String get deleteCard => 'Verwijder Kaart';

  @override
  String get deleteConfirmation =>
      'Weet je zeker dat je deze kaart wilt verwijderen?';

  @override
  String get cancel => 'Annuleren';

  @override
  String get delete => 'Verwijderen';

  @override
  String cardType(Object type) {
    return 'Type: $type';
  }

  @override
  String get title => 'Titel';

  @override
  String get titleHint => 'Voer een titel in voor deze kaart';

  @override
  String get description => 'Omschrijving';

  @override
  String get descriptionHint => 'Voer een omschrijving in';

  @override
  String get barcode => 'Barcode';

  @override
  String get qrCode => 'QR Code';

  @override
  String get barcodeValue => 'Barcode Waarde';

  @override
  String get qrCodeValue => 'QR Code Waarde';

  @override
  String get enterBarcodeValue => 'Voer de barcode waarde in';

  @override
  String get enterQrCodeValue => 'Voer de QR code waarde in';

  @override
  String detectedFormat(Object format) {
    return 'Gedetecteerd: $format';
  }

  @override
  String get noDataScanned => 'Geen data gescand';

  @override
  String get settings => 'Instellingen';

  @override
  String get language => 'Taal';

  @override
  String get selectLanguage => 'Selecteer Taal';

  @override
  String get english => 'Engels';

  @override
  String get spanish => 'Spaans';

  @override
  String get dutch => 'Nederlands';

  @override
  String get deviceLanguage => 'Apparaattaal';

  @override
  String get resetToDeviceLanguage => 'Terugzetten naar Apparaattaal';

  @override
  String get theme => 'Thema';

  @override
  String get selectTheme => 'Selecteer Thema';

  @override
  String get light => 'Licht';

  @override
  String get dark => 'Donker';

  @override
  String get system => 'Systeem';

  @override
  String scanSuccessMessage(Object format) {
    return '$format succesvol gedetecteerd!';
  }

  @override
  String get validationPleaseEnterValue => 'Voer een waarde in';

  @override
  String get validationBarcodeOnlyAlphanumeric =>
      'Barcode mag alleen cijfers en letters bevatten';

  @override
  String get validationBarcodeMinLength =>
      'Barcode moet minimaal 3 tekens lang zijn';

  @override
  String get validationTitleRequired => 'Voer een titel in';

  @override
  String get validationTitleMinLength =>
      'Titel moet minimaal 3 tekens lang zijn';

  @override
  String get validationDescriptionMinLength =>
      'Omschrijving moet minimaal 5 tekens lang zijn';

  @override
  String get textBarcode => 'Barcode';

  @override
  String get textQrCode => 'QR Code';

  @override
  String get search => 'Zoeken';

  @override
  String get noResultsFound => 'Geen resultaten gevonden voor';

  @override
  String get editCard => 'Kaart Bewerken';

  @override
  String get edit => 'Bewerken';

  @override
  String get share => 'Delen';

  @override
  String get shareAsImage => 'Delen als afbeelding';
}

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
  String get ok => 'OK';

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
  String get deviceLanguage => 'Device Language';

  @override
  String get resetToDeviceLanguage => 'Reset to Device Language';

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

  @override
  String get scanInstructionsTooltip => 'Place the barcode in the frame';

  @override
  String get companyOrNameLabel => 'Company/Name';

  @override
  String get codeValueLabel => 'Code Value';

  @override
  String get searchLogoAction => 'Search Logo';

  @override
  String get editAction => 'Edit';

  @override
  String get shareAsImageAction => 'Share as Image';

  @override
  String get removeLogoButton => 'Remove Logo';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get discardButton => 'Discard';

  @override
  String get stayButton => 'Stay';

  @override
  String get cardTypeLabel => 'Card Type';

  @override
  String get save => 'Save';

  @override
  String get currentLogo => 'Current Logo';

  @override
  String get searchLogoHint => 'Enter company name for logo';

  @override
  String get logoSearchFailedTitle => 'Logo Search Failed';

  @override
  String get logoSearchFailedMessage =>
      'Could not find a logo for the entered name. Please try a different name or check your internet connection.';

  @override
  String get logoDownloadFailedTitle => 'Logo Download Failed';

  @override
  String get logoDownloadFailedMessage =>
      'Could not download the selected logo. Please check your internet connection and try again.';

  @override
  String get scanFromImageAction => 'Scan from Image';

  @override
  String get noBarcodeFoundInImage =>
      'No barcode or QR code found in the selected image.';

  @override
  String get scanFromImageTitle => 'Scan from Image';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get selectImageButton => 'Select Image';

  @override
  String get scanFromImageSubtitle => 'Select an image from your gallery';

  @override
  String get manualEntrySubtitle => 'Type in the code manually';

  @override
  String get scanFromImageInstructions =>
      'Select an image from your gallery that contains a QR code or barcode';
}

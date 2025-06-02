import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards - QR Scanner'**
  String get appTitle;

  /// No description provided for @myCards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get myCards;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @noCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards yet. Add your first card!'**
  String get noCardsYet;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card?'**
  String get deleteConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cardType.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String cardType(Object type);

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for this card'**
  String get titleHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get descriptionHint;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @barcodeValue.
  ///
  /// In en, this message translates to:
  /// **'Barcode Value'**
  String get barcodeValue;

  /// No description provided for @qrCodeValue.
  ///
  /// In en, this message translates to:
  /// **'QR Code Value'**
  String get qrCodeValue;

  /// No description provided for @enterBarcodeValue.
  ///
  /// In en, this message translates to:
  /// **'Enter the barcode value'**
  String get enterBarcodeValue;

  /// No description provided for @enterQrCodeValue.
  ///
  /// In en, this message translates to:
  /// **'Enter the QR code value'**
  String get enterQrCodeValue;

  /// No description provided for @detectedFormat.
  ///
  /// In en, this message translates to:
  /// **'Detected: {format}'**
  String detectedFormat(Object format);

  /// No description provided for @noDataScanned.
  ///
  /// In en, this message translates to:
  /// **'No data scanned'**
  String get noDataScanned;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get dutch;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @scanSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{format} detected successfully!'**
  String scanSuccessMessage(Object format);

  /// No description provided for @validationPleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get validationPleaseEnterValue;

  /// No description provided for @validationBarcodeOnlyAlphanumeric.
  ///
  /// In en, this message translates to:
  /// **'Barcode can only contain numbers and letters'**
  String get validationBarcodeOnlyAlphanumeric;

  /// No description provided for @validationBarcodeMinLength.
  ///
  /// In en, this message translates to:
  /// **'Barcode should be at least 3 characters'**
  String get validationBarcodeMinLength;

  /// No description provided for @validationTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get validationTitleRequired;

  /// No description provided for @validationTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title should be at least 3 characters'**
  String get validationTitleMinLength;

  /// No description provided for @validationDescriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description should be at least 5 characters'**
  String get validationDescriptionMinLength;

  /// No description provided for @textBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get textBarcode;

  /// No description provided for @textQrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get textQrCode;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for'**
  String get noResultsFound;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImage;

  /// No description provided for @scanInstructionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Place the barcode in the frame'**
  String get scanInstructionsTooltip;

  /// No description provided for @companyOrNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company/Name'**
  String get companyOrNameLabel;

  /// No description provided for @codeValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Code Value'**
  String get codeValueLabel;

  /// No description provided for @searchLogoAction.
  ///
  /// In en, this message translates to:
  /// **'Search Logo'**
  String get searchLogoAction;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @shareAsImageAction.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImageAction;

  /// No description provided for @removeLogoButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Logo'**
  String get removeLogoButton;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get unsavedChangesMessage;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @stayButton.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stayButton;

  /// No description provided for @cardTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get cardTypeLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currentLogo.
  ///
  /// In en, this message translates to:
  /// **'Current Logo'**
  String get currentLogo;

  /// No description provided for @searchLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter company name for logo'**
  String get searchLogoHint;

  /// No description provided for @logoSearchFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Logo Search Failed'**
  String get logoSearchFailedTitle;

  /// No description provided for @logoSearchFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not find a logo for the entered name. Please try a different name or check your internet connection.'**
  String get logoSearchFailedMessage;

  /// No description provided for @logoDownloadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Logo Download Failed'**
  String get logoDownloadFailedTitle;

  /// No description provided for @logoDownloadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not download the selected logo. Please check your internet connection and try again.'**
  String get logoDownloadFailedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

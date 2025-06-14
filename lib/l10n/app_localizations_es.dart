// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tarjetas - Escáner QR';

  @override
  String get myCards => 'Mis Tarjetas';

  @override
  String get addCard => 'Añadir Tarjeta';

  @override
  String get scanBarcode => 'Escanear Código';

  @override
  String get manualEntry => 'Entrada Manual';

  @override
  String get noCardsYet => 'No hay tarjetas todavía. ¡Añade tu primera tarjeta!';

  @override
  String get deleteCard => 'Eliminar Tarjeta';

  @override
  String get deleteConfirmation => '¿Estás seguro de que quieres eliminar esta tarjeta?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get ok => 'Aceptar';

  @override
  String cardType(Object type) {
    return 'Tipo: $type';
  }

  @override
  String get title => 'Título';

  @override
  String get titleHint => 'Introduce un título para esta tarjeta';

  @override
  String get description => 'Descripción';

  @override
  String get descriptionHint => 'Introduce una descripción';

  @override
  String get barcode => 'Código de Barras';

  @override
  String get qrCode => 'Código QR';

  @override
  String get barcodeValue => 'Valor del Código de Barras';

  @override
  String get qrCodeValue => 'Valor del Código QR';

  @override
  String get enterBarcodeValue => 'Introduce el valor del código de barras';

  @override
  String get enterQrCodeValue => 'Introduce el valor del código QR';

  @override
  String detectedFormat(Object format) {
    return 'Detectado: $format';
  }

  @override
  String get noDataScanned => 'No se ha escaneado ningún dato';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get dutch => 'Holandés';

  @override
  String get theme => 'Tema';

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String scanSuccessMessage(Object format) {
    return '¡$format detectado con éxito!';
  }

  @override
  String get validationPleaseEnterValue => 'Por favor ingrese un valor';

  @override
  String get validationBarcodeOnlyAlphanumeric => 'El código de barras solo puede contener números y letras';

  @override
  String get validationBarcodeMinLength => 'El código de barras debe tener al menos 3 caracteres';

  @override
  String get validationTitleRequired => 'Por favor ingrese un título';

  @override
  String get validationTitleMinLength => 'El título debe tener al menos 3 caracteres';

  @override
  String get validationDescriptionMinLength => 'La descripción debe tener al menos 5 caracteres';

  @override
  String get textBarcode => 'Código de Barras';

  @override
  String get textQrCode => 'Código QR';

  @override
  String get search => 'Buscar';

  @override
  String get noResultsFound => 'No se encontraron resultados para';

  @override
  String get editCard => 'Editar Tarjeta';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Compartir';

  @override
  String get shareAsImage => 'Compartir como imagen';

  @override
  String get scanInstructionsTooltip => 'Coloca el código de barras en el marco';

  @override
  String get companyOrNameLabel => 'Empresa/Nombre';

  @override
  String get codeValueLabel => 'Valor del Código';

  @override
  String get searchLogoAction => 'Buscar Logo';

  @override
  String get editAction => 'Editar';

  @override
  String get shareAsImageAction => 'Compartir como imagen';

  @override
  String get removeLogoButton => 'Eliminar Logo';

  @override
  String get unsavedChangesTitle => 'Cambios no guardados';

  @override
  String get unsavedChangesMessage => 'Tienes cambios sin guardar. ¿Quieres descartarlos?';

  @override
  String get discardButton => 'Descartar';

  @override
  String get stayButton => 'Permanecer';

  @override
  String get cardTypeLabel => 'Tipo de Tarjeta';

  @override
  String get save => 'Guardar';

  @override
  String get currentLogo => 'Logo Actual';

  @override
  String get searchLogoHint => 'Introduce el nombre de la empresa para el logo';

  @override
  String get logoSearchFailedTitle => 'Error en la Búsqueda de Logos';

  @override
  String get logoSearchFailedMessage => 'No se pudo encontrar un logo para el nombre ingresado. Por favor, intente con un nombre diferente o verifique su conexión a internet.';

  @override
  String get logoDownloadFailedTitle => 'Error en la Descarga del Logo';

  @override
  String get logoDownloadFailedMessage => 'No se pudo descargar el logo seleccionado. Por favor, verifique su conexión a internet e intente de nuevo.';

  @override
  String get scanFromImageAction => 'Escanear desde Imagen';

  @override
  String get noBarcodeFoundInImage => 'No se encontró ningún código de barras o código QR en la imagen seleccionada.';

  @override
  String get scanFromImageTitle => 'Escanear desde Imagen';

  @override
  String get processingImage => 'Procesando imagen...';

  @override
  String get selectImageButton => 'Seleccionar Imagen';

  @override
  String get scanFromImageSubtitle => 'Selecciona una imagen de tu galería';

  @override
  String get manualEntrySubtitle => 'Escribe el código manualmente';

  @override
  String get scanFromImageInstructions => 'Selecciona una imagen de tu galería que contenga un código QR o código de barras';
}

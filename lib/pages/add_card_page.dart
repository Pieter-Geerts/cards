import 'dart:io';

import 'package:fl_mlkit_scanning/fl_mlkit_scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile;

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../models/code_renderer.dart';
import '../pages/home_page.dart' show buildLogoWidget;

class AddCardPage extends StatelessWidget {
  const AddCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AddCardFlowController();
  }
}

class _AddCardFlowController extends StatefulWidget {
  @override
  State<_AddCardFlowController> createState() => _AddCardFlowControllerState();
}

class _AddCardFlowControllerState extends State<_AddCardFlowController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showEntryModal());
  }

  void _showEntryModal() async {
    // Create the modal here using current context
    final l10n = AppLocalizations.of(context);
    final result = await showModalBottomSheet<_AddCardEntryResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => _AddCardEntryModal(l10n: l10n),
    );

    // Check if the widget is still mounted after the async operation
    if (!mounted) return;

    // Use the current context (not a cached one) after checking mounted
    if (result == _AddCardEntryResult.scan) {
      _goToScan();
    } else if (result == _AddCardEntryResult.manual) {
      _goToDetails(null, null, CardType.qrCode);
    } else if (result == _AddCardEntryResult.scanFromImage) {
      _goToScanFromImage(); // New handler
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToScan() async {
    final scanResult = await Navigator.of(
      context,
    ).push<_ScanResult?>(MaterialPageRoute(builder: (_) => _ScanCardPage()));

    // Check if the widget is still mounted after the async operation
    if (!mounted) return;

    // Use the current context (not a cached one) after checking mounted
    if (scanResult != null && scanResult.data != null) {
      _goToDetails(scanResult.data, scanResult.type, scanResult.cardType);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToDetails(String? code, String? type, CardType cardType) async {
    final card = await Navigator.of(context).push<CardItem?>(
      MaterialPageRoute(
        builder:
            (_) => _AddCardDetailsPage(
              initialCode: code,
              initialType: type,
              initialCardType: cardType,
            ),
      ),
    );

    // Check if the widget is still mounted after the async operation
    if (!mounted) return;

    // Use the current context (not a cached one) after checking mounted
    if (card != null) {
      Navigator.of(context).pop(card);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToScanFromImage() async {
    final scanResult = await Navigator.of(context).push<_ScanResult?>(
      MaterialPageRoute(builder: (_) => _ScanFromImagePage()),
    );

    if (!mounted) return;

    if (scanResult != null && scanResult.data != null) {
      _goToDetails(scanResult.data, scanResult.type, scanResult.cardType);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Empty container, all UI is handled by navigation
    return const SizedBox.shrink();
  }
}

// --- PHASE 1: Entry Modal ---
enum _AddCardEntryResult { scan, manual, scanFromImage }

class _AddCardEntryModal extends StatelessWidget {
  final AppLocalizations l10n;
  const _AddCardEntryModal({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addCard,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),

            // Primary action - Live scanning with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text(
                  l10n.scanBarcode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    () => Navigator.of(context).pop(_AddCardEntryResult.scan),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).or,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Secondary actions in a card layout
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _buildOptionTile(
                    context,
                    icon: Icons.photo_library,
                    title: l10n.scanFromImageAction,
                    subtitle: l10n.scanFromImageSubtitle,
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pop(_AddCardEntryResult.scanFromImage),
                  ),
                  Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                  _buildOptionTile(
                    context,
                    icon: Icons.edit,
                    title: l10n.manualEntry,
                    subtitle: l10n.manualEntrySubtitle,
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pop(_AddCardEntryResult.manual),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

// --- PHASE 2: Scan Page ---
class _ScanResult {
  final String? data;
  final String? type;
  final CardType cardType;
  _ScanResult(this.data, this.type, this.cardType);
}

class _ScanCardPage extends StatefulWidget {
  @override
  State<_ScanCardPage> createState() => _ScanCardPageState();
}

class _ScanCardPageState extends State<_ScanCardPage> {
  String? _scannedData;
  String? _detectedFormatString;
  CardType _detectedCardType = CardType.qrCode;
  bool _isScanning = true;

  void _onDetect(mobile.BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _scannedData = barcode.rawValue;
          final formatName = barcode.format.toString();
          if (formatName.toLowerCase().contains("qr")) {
            _detectedFormatString = "QR Code";
            _detectedCardType = CardType.qrCode;
          } else {
            _detectedFormatString = "Barcode";
            _detectedCardType = CardType.barcode;
          }
          _isScanning = false;
        });
        HapticFeedback.mediumImpact();

        // Store values now as we'll need them after the delay
        final scannedData = _scannedData;
        final detectedFormatString = _detectedFormatString;
        final detectedCardType = _detectedCardType;

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(
              _ScanResult(scannedData, detectedFormatString, detectedCardType),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanBarcode),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: mobile.MobileScanner(fit: BoxFit.cover, onDetect: _onDetect),
          ),
          Center(
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              l10n.scanInstructionsTooltip,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Scan from Image Page ---
class _ScanFromImagePage extends StatefulWidget {
  @override
  State<_ScanFromImagePage> createState() => _ScanFromImagePageState();
}

class _ScanFromImagePageState extends State<_ScanFromImagePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  File? _selectedImage;
  String? _errorMessage;

  Future<void> _pickAndScanImage() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimize for processing
      );

      if (image == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final imageFile = File(image.path);
      setState(() => _selectedImage = imageFile);

      // Read image file as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Use the controller to scan the image bytes
      final FlMlKitScanningController controller = FlMlKitScanningController();
      await controller.initialize();

      final AnalysisImageModel? result = await controller.scanningImageByte(
        imageBytes,
      );

      if (!mounted) return;

      if (result != null &&
          result.barcodes != null &&
          result.barcodes!.isNotEmpty) {
        final barcode = result.barcodes!.first;
        String? detectedFormatString;
        CardType detectedCardType;

        // Determine type based on BarcodeFormat
        if (barcode.format == BarcodeFormat.qrCode) {
          detectedFormatString = "QR Code";
          detectedCardType = CardType.qrCode;
        } else {
          detectedFormatString = "Barcode";
          detectedCardType = CardType.barcode;
        }

        Navigator.of(context).pop(
          _ScanResult(barcode.value, detectedFormatString, detectedCardType),
        );
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context).noBarcodeFoundInImage;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error scanning image: ${e.toString()}';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanFromImageTitle), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.scanFromImageInstructions,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Image preview area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                if (_isProcessing)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Scanning...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.selectImageButton,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Action buttons - always show the select image button
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: Text(
                          _selectedImage != null
                              ? 'Try Another Image'
                              : l10n.selectImageButton,
                        ),
                        onPressed: _isProcessing ? null : _pickAndScanImage,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    if (_selectedImage != null && _errorMessage != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Scan Again'),
                          onPressed:
                              _isProcessing ? null : () => _pickAndScanImage(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PHASE 3: Card Details/Confirmation Page ---
class _AddCardDetailsPage extends StatefulWidget {
  final String? initialCode;
  final String? initialType;
  final CardType initialCardType;
  const _AddCardDetailsPage({
    this.initialCode,
    this.initialType,
    required this.initialCardType,
  });

  @override
  State<_AddCardDetailsPage> createState() => _AddCardDetailsPageState();
}

class _AddCardDetailsPageState extends State<_AddCardDetailsPage> {
  late CardType _selectedCardType;
  late TextEditingController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _logoPath;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedCardType = widget.initialCardType;
    _codeController = TextEditingController(text: widget.initialCode ?? '');
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  String? _validateCode(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.validationPleaseEnterValue;
    }

    // Use the code renderer validation
    final renderer = CodeRendererFactory.getRenderer(_selectedCardType);
    if (!renderer.validateData(value)) {
      if (_selectedCardType == CardType.barcode) {
        return l10n.validationBarcodeOnlyAlphanumeric;
      } else {
        return 'Invalid data for ${_selectedCardType.displayName}';
      }
    }

    return null;
  }

  String? _validateTitle(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.validationTitleRequired;
    }
    if (value.length < 3) {
      return l10n.validationTitleMinLength;
    }
    return null;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCard),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Code preview
              if (_codeController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: CardItem.temp(
                      title: 'Preview',
                      description: '',
                      name: _codeController.text,
                      cardType: _selectedCardType,
                    ).renderCode(
                      size: _selectedCardType.is2D ? 160 : null,
                      width: _selectedCardType.is1D ? 200 : null,
                      height: _selectedCardType.is1D ? 80 : null,
                    ),
                  ),
                ),
              // Card type selection
              DropdownButtonFormField<CardType>(
                decoration: InputDecoration(
                  labelText: 'Card Type',
                  border: const OutlineInputBorder(),
                ),
                value: _selectedCardType,
                items:
                    CardType.values.map((cardType) {
                      return DropdownMenuItem(
                        value: cardType,
                        child: Text(cardType.displayName),
                      );
                    }).toList(),
                onChanged: (CardType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCardType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText:
                      _selectedCardType == CardType.barcode
                          ? l10n.barcodeValue
                          : l10n.qrCodeValue,
                  hintText:
                      _selectedCardType == CardType.barcode
                          ? l10n.enterBarcodeValue
                          : l10n.enterQrCodeValue,
                  border: const OutlineInputBorder(),
                ),
                validator: _validateCode,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  hintText: l10n.titleHint,
                  border: const OutlineInputBorder(),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.descriptionHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Logo display (if set)
              if (_logoPath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: buildLogoWidget(
                      _logoPath!,
                      title: _titleController.text,
                    ),
                  ),
                ),
              if (_logoPath != null)
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text('Remove Logo'),
                  onPressed: () => setState(() => _logoPath = null),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(
                      CardItem.temp(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        name: _codeController.text,
                        cardType: _selectedCardType,
                        logoPath: _logoPath,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(l10n.addCard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

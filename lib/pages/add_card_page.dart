import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile;
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/home_page.dart' show buildLogoWidget;
import '../secrets.dart';
import '../services/logo_dev_service.dart';

enum CardType { BARCODE, QR_CODE }

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
    final l10n = AppLocalizations.of(context);
    final result = await showModalBottomSheet<_AddCardEntryResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddCardEntryModal(l10n: l10n),
    );
    if (result == _AddCardEntryResult.scan) {
      _goToScan();
    } else if (result == _AddCardEntryResult.manual) {
      _goToDetails(null, null, CardType.QR_CODE);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToScan() async {
    final scanResult = await Navigator.of(
      context,
    ).push<_ScanResult?>(MaterialPageRoute(builder: (_) => _ScanCardPage()));
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
    if (card != null) {
      Navigator.of(context).pop(card);
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
enum _AddCardEntryResult { scan, manual }

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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.scanBarcode),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed:
                  () => Navigator.of(context).pop(_AddCardEntryResult.scan),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text(l10n.manualEntry),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed:
                  () => Navigator.of(context).pop(_AddCardEntryResult.manual),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
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
  CardType _detectedCardType = CardType.QR_CODE;
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
            _detectedCardType = CardType.QR_CODE;
          } else {
            _detectedFormatString = "Barcode";
            _detectedCardType = CardType.BARCODE;
          }
          _isScanning = false;
        });
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pop(
            _ScanResult(_scannedData, _detectedFormatString, _detectedCardType),
          );
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
              'Position the barcode/QR code within the frame',
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
  late TextEditingController _logoSearchController;
  String? _logoPath;
  bool _isSearchingLogo = false;
  List<Map<String, dynamic>> _searchResults = [];
  late LogoDevService _logoService;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedCardType = widget.initialCardType;
    _codeController = TextEditingController(text: widget.initialCode ?? '');
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _logoSearchController = TextEditingController();
    _logoService = LogoDevService(logoDevApiKey);
    _titleController.addListener(_autoSearchLogoFromTitle);
  }

  void _autoSearchLogoFromTitle() async {
    final title = _titleController.text.trim();
    if (title.isNotEmpty && title.length > 2) {
      setState(() => _isSearchingLogo = true);
      final results = await _logoService.searchCompanies(title);
      setState(() {
        _searchResults = results;
        _isSearchingLogo = false;
      });
    } else {
      setState(() => _searchResults = []);
    }
  }

  Future<void> _searchLogo(String query) async {
    setState(() => _isSearchingLogo = true);
    final results = await _logoService.searchCompanies(query);
    setState(() {
      _searchResults = results;
      _isSearchingLogo = false;
    });
  }

  Future<void> _downloadAndSetLogo(String companyNameOrDomain) async {
    setState(() => _isSearchingLogo = true);
    final filePath = await _logoService.downloadAndSaveLogo(
      companyNameOrDomain,
    );
    setState(() {
      _logoPath = filePath;
      _searchResults = [];
      _logoSearchController.text = '';
      _isSearchingLogo = false;
    });
  }

  String? _validateCode(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.validationPleaseEnterValue;
    }
    if (_selectedCardType == CardType.BARCODE) {
      if (!RegExp(r'^[0-9a-zA-Z]+$').hasMatch(value)) {
        return l10n.validationBarcodeOnlyAlphanumeric;
      }
      if (value.length < 3) {
        return l10n.validationBarcodeMinLength;
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
    _titleController.removeListener(_autoSearchLogoFromTitle);
    _logoSearchController.dispose();
    _codeController.dispose();
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
                    child:
                        _selectedCardType == CardType.QR_CODE
                            ? QrImageView(
                              data: _codeController.text,
                              version: QrVersions.auto,
                              size: 160,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            )
                            : bw.BarcodeWidget(
                              barcode: bw.Barcode.code128(),
                              data: _codeController.text,
                              drawText: false,
                              color: Colors.black,
                              backgroundColor: Colors.white,
                              width: 200,
                              height: 80,
                            ),
                  ),
                ),
              // Card type toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(l10n.barcode),
                      selected: _selectedCardType == CardType.BARCODE,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCardType = CardType.BARCODE;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(l10n.qrCode),
                      selected: _selectedCardType == CardType.QR_CODE,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCardType = CardType.QR_CODE;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText:
                      _selectedCardType == CardType.BARCODE
                          ? l10n.barcodeValue
                          : l10n.qrCodeValue,
                  hintText:
                      _selectedCardType == CardType.BARCODE
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
              // Logo search and preview
              TextField(
                controller: _logoSearchController,
                decoration: InputDecoration(
                  labelText: 'Search company logo',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchLogo(_logoSearchController.text),
                  ),
                ),
                onSubmitted: (query) => _searchLogo(query),
              ),
              if (_isSearchingLogo)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_searchResults.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (result['logo_url'] != null &&
                                result['logo_url'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  result['logo_url'],
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            Text(result['name'] ?? ''),
                          ],
                        ),
                        selected: false,
                        onSelected:
                            (_) => _downloadAndSetLogo(
                              result['domain'] ?? result['name'] ?? '',
                            ),
                      );
                    },
                  ),
                ),
              if (_logoPath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(child: buildLogoWidget(_logoPath!)),
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
                        cardType: _selectedCardType.name,
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

// ignore_for_file: library_private_types_in_public_api
// All imports must be at the very top
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/preset_cards.dart';
import '../helpers/image_scan_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/camera_scan_page.dart';
import '../pages/image_scan_page.dart';
import '../services/logo_cache_service.dart';
import '../utils/simple_icons_mapping.dart';
import 'add_card_steps/add_card_options.dart';
import 'add_card_steps/add_card_step_details.dart';
import 'add_card_steps/add_card_step_preset.dart';
import 'logo_selection_sheet.dart';

class AddCardBottomSheet extends StatefulWidget {
  final Function(CardItem) onCardCreated;

  const AddCardBottomSheet({super.key, required this.onCardCreated});

  @override
  _AddCardBottomSheetState createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  // search removed for preset selection
  final PageController _pageController = PageController();
  int _currentStep = 0;
  // Step 1: selection
  PresetCard? _selectedPreset;
  bool _isGenericSelected = false;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // State
  CardType _cardType = CardType.qrCode;
  String? _logoPath;
  IconData? _selectedLogoIcon;
  final ValueNotifier<bool> _showManualEntry = ValueNotifier(false);

  // Performance optimization
  Timer? _debounceTimer;
  bool _canProceed = false;
  bool _isLogoLoading = false;

  // Cache frequently used values to avoid repeated calculations
  String _lastTitleValue = '';
  String _lastCodeValue = '';

  void _openLogoSelectionSheet(BuildContext context) {
    showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LogoSelectionSheet(),
    ).then((selectedIdentifier) {
      if (selectedIdentifier != null && mounted) {
        setState(() {
          _logoPath = selectedIdentifier;
          _selectedLogoIcon = SimpleIconsMapping.getIcon(selectedIdentifier);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to optimize setState calls
    _titleController.addListener(_onTitleChanged);
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.dispose();
    _titleController.removeListener(_onTitleChanged);
    _codeController.removeListener(_onCodeChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final currentValue = _titleController.text.trim();

    // Only proceed if value actually changed to avoid unnecessary updates
    if (_lastTitleValue == currentValue) return;
    _lastTitleValue = currentValue;

    final canProceed = currentValue.isNotEmpty;
    if (_canProceed != canProceed) {
      setState(() {
        _canProceed = canProceed;
      });
    }
    _debouncedLogoSuggestion();
  }

  void _onCodeChanged() {
    final currentValue = _codeController.text.trim();

    // Only proceed if value actually changed to avoid unnecessary updates
    if (_lastCodeValue == currentValue) return;
    _lastCodeValue = currentValue;

    final canProceed = currentValue.isNotEmpty;
    // Ensure the proceed button updates when on the code acquisition step (index 2)
    if (_currentStep == 2 && _canProceed != canProceed) {
      setState(() {
        _canProceed = canProceed;
      });
    }
  }

  void _debouncedLogoSuggestion() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted &&
          _selectedLogoIcon == null &&
          _titleController.text.trim().isNotEmpty) {
        _suggestLogoFromTitle();
      }
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    if (_currentStep == page) return;
    setState(() {
      _currentStep = page;
      if (page == 1) {
        // If preset selected, prefill title/logo and skip manual entry
        if (_selectedPreset != null) {
          _titleController.text = _selectedPreset!.title;
          _selectedLogoIcon = _selectedPreset!.logoIcon;
        } else if (_isGenericSelected) {
          _titleController.clear();
          _selectedLogoIcon = null;
        }
      }
      // Update _canProceed for each step
      if (page == 0) {
        _canProceed = _selectedPreset != null || _isGenericSelected;
      } else if (page == 1) {
        _canProceed =
            _isGenericSelected ? _titleController.text.trim().isNotEmpty : true;
      } else {
        _canProceed = _codeController.text.trim().isNotEmpty;
      }
    });
  }

  Future<void> _suggestLogoFromTitle() async {
    if (_isLogoLoading) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // Use optimized cache service instead of direct LogoHelper for performance
    _isLogoLoading = true;

    try {
      // Use the optimized cache service with timeout protection
      final cacheService = LogoCacheService.instance;
      final suggestion = await cacheService
          .getSuggestedLogo(title)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (!mounted) return;

      // Only update if we don't have a manually selected logo
      if (suggestion != null && _selectedLogoIcon == null) {
        _selectedLogoIcon = suggestion;
      }
    } catch (e) {
      debugPrint('Logo suggestion error: $e');
    } finally {
      if (mounted) {
        _isLogoLoading = false;
      }
    }
  }

  void _startScan() async {
    // Navigate to camera scanner
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CameraScanPage(
              onCodeScanned: (code, type) {
                if (mounted) {
                  setState(() {
                    _codeController.text = code;
                    _cardType = type;
                  });
                  _nextStep();
                }
              },
            ),
      ),
    );
  }

  void _startManualEntry() {
    setState(() {
      _showManualEntry.value = true;
    });
  }

  void _startImageImport() async {
    try {
      // Show image selection options
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final l = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l.importFromImage),
            content: Text(l.scanFromImageSubtitle),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('gallery'),
                child: Text(l.selectImageButton),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('camera'),
                child: Text(l.choosePhotoWithBarcode),
              ),
            ],
          );
        },
      );

      if (result != null && mounted) {
        Map<String, dynamic>? scanResult;

        if (result == 'gallery') {
          scanResult = await ImageScanHelper.pickAndScanImage();
        } else if (result == 'camera') {
          scanResult = await ImageScanHelper.takePhotoAndScan();
        }

        if (scanResult != null && mounted) {
          final result = scanResult; // Promote to non-null
          final imagePath = result['imagePath'] as String?;
          final hasAutoDetection = result['hasAutoDetection'] as bool? ?? false;

          if (hasAutoDetection &&
              result['code'] != null &&
              result['code'].isNotEmpty) {
            // Auto-detected code, pre-fill and continue
            setState(() {
              _codeController.text = (result['code'] as String?) ?? '';
              _cardType = (result['type'] as CardType?) ?? CardType.qrCode;
            });
            _nextStep();
          } else if (imagePath != null) {
            // Show image for manual entry
            final codeResult = await Navigator.of(
              context,
            ).push<Map<String, dynamic>>(
              MaterialPageRoute(
                builder:
                    (context) => ImageScanPage(
                      imagePath: imagePath,
                      onCodeEntered: (code, type) {
                        Navigator.of(context).pop({'code': code, 'type': type});
                      },
                    ),
              ),
            );

            if (codeResult != null && mounted) {
              setState(() {
                _codeController.text = codeResult['code'] ?? '';
                _cardType = codeResult['type'] ?? CardType.qrCode;
              });
              _nextStep();
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).importError}: $e'),
          ),
        );
      }
    }
  }

  bool _canProceedFromStep(int step) {
    if (step == 0) {
      return _selectedPreset != null || _isGenericSelected;
    } else if (step == 1) {
      return _isGenericSelected
          ? _titleController.text.trim().isNotEmpty
          : true;
    } else {
      return _codeController.text.trim().isNotEmpty;
    }
  }

  bool _shouldShowPreview() {
    // Only show preview when there's meaningful content
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Show preview if:
    // 1. Title has at least 3 characters
    // 2. AND either description has content OR a logo is selected
    return title.length >= 3 &&
        (description.isNotEmpty ||
            _logoPath != null ||
            _selectedLogoIcon != null);
  }

  Future<void> _saveCard() async {
    // Always try to set logoPath using helper, fallback to initials if not found
    String? logoPath;
    if (_selectedLogoIcon != null && _logoPath == null) {
      logoPath = _getSimpleIconIdentifier(_selectedLogoIcon!);
    } else if (_logoPath != null) {
      logoPath = _logoPath;
    } else {
      logoPath = _getLogoPathForTitle(_titleController.text.trim());
    }
    final newCard = CardItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      name: _codeController.text.trim(),
      cardType: _cardType,
      logoPath: logoPath,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );
    widget.onCardCreated(newCard);
  }

  String? _getSimpleIconIdentifier(IconData icon) {
    return SimpleIconsMapping.getIdentifier(icon);
  }

  /// Returns a SimpleIcons identifier for supported brands, or null for initials fallback
  String? _getLogoPathForTitle(String title) {
    final normalized = title.trim().toLowerCase().replaceAll(' ', '');
    for (final entry in SimpleIconsMapping.iconToIdentifier.entries) {
      final key = entry.value.replaceAll('simple_icon:', '').toLowerCase();
      if (normalized.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Drag handle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? theme.dividerColor : theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Custom app bar
          Container(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
            child: Column(
              children: [
                // Step indicator
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      // Progress bar
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width:
                                    MediaQuery.of(context).size.width *
                                    ((_currentStep + 1) / 3) *
                                    0.85, // Full width progress
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Step counter
                      Text(
                        AppLocalizations.of(
                          context,
                        ).stepCounter(_currentStep + 1, 3),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  _getStepTitle(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildPresetSelectionStep(),
                _buildCardDetailsStep(),
                _buildCodeAcquisitionStep(),
              ],
            ),
          ),

          // Enhanced bottom action area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Show Cancel button on first step, Back button on subsequent steps
                  if (_currentStep == 0)
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 2,
                          ),
                          color: colorScheme.surface,
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            foregroundColor: theme.textTheme.bodyLarge?.color,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                color: theme.iconTheme.color?.withAlpha(230),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).cancel,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0)
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 2,
                          ),
                          color: colorScheme.surface,
                        ),
                        child: TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            foregroundColor: theme.textTheme.bodyLarge?.color,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                color: theme.iconTheme.color?.withAlpha(230),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).previous,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Container(
                      height: 56, // Increased height for better touch target
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient:
                            _canProceedFromStep(_currentStep)
                                ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primaryContainer,
                                  ],
                                )
                                : null,
                        color:
                            !_canProceedFromStep(_currentStep)
                                ? theme.disabledColor.withAlpha(31)
                                : null,
                        boxShadow:
                            _canProceedFromStep(_currentStep)
                                ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withAlpha(51),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                                : null,
                      ),
                      child: ElevatedButton(
                        onPressed:
                            _canProceedFromStep(_currentStep)
                                ? (_currentStep == 2 ? _saveCard : _nextStep)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == 2
                                  ? AppLocalizations.of(context).save
                                  : AppLocalizations.of(context).next,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color:
                                    _canProceedFromStep(_currentStep)
                                        ? colorScheme.onPrimary
                                        : theme.disabledColor.withAlpha(204),
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_currentStep < 2 &&
                                _canProceedFromStep(_currentStep)) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                            if (_currentStep == 2 &&
                                _canProceedFromStep(_currentStep)) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelectionStep() {
    return AddCardStepPreset(
      selectedPreset: _selectedPreset,
      isGenericSelected: _isGenericSelected,
      onPresetSelected: (preset) {
        setState(() {
          _selectedPreset = preset;
          _isGenericSelected = false;
        });
      },
      onGenericSelected: (selected) {
        setState(() {
          _selectedPreset = null;
          _isGenericSelected = selected;
        });
      },
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return AppLocalizations.of(context).wizardStepBasicInfo;
      case 1:
        return AppLocalizations.of(context).wizardStepCodeAndFinish;
      default:
        return '';
    }
  }

  Widget _buildCodeAcquisitionStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Enhanced title with better typography
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppLocalizations.of(context).howAddCode,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Enhanced scan option with modern styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AddCardPrimaryOption(
              icon: Icons.qr_code_scanner_outlined,
              title: AppLocalizations.of(context).scanBarcodeCTA,
              subtitle: AppLocalizations.of(context).useCameraToScan,
              color: Theme.of(context).colorScheme.primary,
              onTap: _startScan,
            ),
          ),

          const SizedBox(height: 24),

          // Enhanced divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context).or,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Enhanced secondary options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildSecondaryOption(
                  context: context,
                  icon: Icons.photo_library_outlined,
                  title: AppLocalizations.of(context).importFromImage,
                  subtitle: AppLocalizations.of(context).choosePhotoWithBarcode,
                  onTap: _startImageImport,
                ),

                const SizedBox(height: 16),

                _buildSecondaryOption(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: AppLocalizations.of(context).manualEntryFull,
                  subtitle: AppLocalizations.of(context).typeCodeManually,
                  onTap: _startManualEntry,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Enhanced manual code entry section
          if (_showManualEntry.value) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(51),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).manualEntryFull,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Enhanced card type dropdown
                  Text(
                    AppLocalizations.of(context).cardTypeLabel,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(
                            0x08000000,
                          ), // Static color for performance (0.03 opacity)
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<CardType>(
                      value: _cardType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).inputDecorationTheme.fillColor ??
                            Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      items:
                          CardType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                      onChanged: (CardType? value) {
                        setState(() {
                          _cardType = value ?? CardType.qrCode;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced code input
                  Text(
                    AppLocalizations.of(context).code,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(
                            0x08000000,
                          ), // Static color for performance (0.03 opacity)
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _codeController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            _cardType == CardType.qrCode
                                ? AppLocalizations.of(context).enterQrCodeValue
                                : AppLocalizations.of(
                                  context,
                                ).enterBarcodeValue,
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).hintColor,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).inputDecorationTheme.fillColor ??
                            Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.qr_code_outlined,
                          color: Theme.of(context).hintColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.paste_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          tooltip:
                              AppLocalizations.of(context).pasteFromClipboard,
                          onPressed: () async {
                            try {
                              final clipboardData = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              final text = clipboardData?.text ?? '';
                              if (text.isNotEmpty && mounted) {
                                setState(() {
                                  _codeController.text = text.trim();
                                });
                              }
                            } catch (_) {
                              // ignore errors when accessing clipboard
                            }
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      // Removed onChanged to prevent excessive setState calls - using listeners instead
                    ),
                  ),

                  // Live small preview of the entered code so users can verify before continuing
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _codeController,
                    builder: (context, _) {
                      final codeText = _codeController.text.trim();
                      if (codeText.isEmpty) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceTint.withAlpha(18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                codeText,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy_outlined,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              tooltip: 'Kopieer code',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await Clipboard.setData(
                                  ClipboardData(text: codeText),
                                );
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).codeCopiedToClipboard,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCardDetailsStep() {
    return AddCardStepDetails(
      titleController: _titleController,
      descriptionController: _descriptionController,
      selectedLogoIcon: _selectedLogoIcon,
      onLogoTap: () => _openLogoSelectionSheet(context),
      shouldShowPreview: _shouldShowPreview(),
      previewWidget:
          _shouldShowPreview()
              ? _CardPreviewOptimized(
                logoPath:
                    _selectedLogoIcon != null && _logoPath == null
                        ? _getSimpleIconIdentifier(_selectedLogoIcon!)
                        : _logoPath,
                title: _titleController.text,
                description: _descriptionController.text,
                logoSize: 52,
                background: Colors.transparent,
              )
              : null,
    );
  }
}

Widget _buildSecondaryOption({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Container(
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.dividerColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withAlpha(10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.dividerColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Optimized preview widget that reduces rebuilds by caching values
class _CardPreviewOptimized extends StatefulWidget {
  final String? logoPath;
  final String title;
  final String description;
  final double logoSize;
  final Color? background;

  const _CardPreviewOptimized({
    required this.logoPath,
    required this.title,
    required this.description,
    this.logoSize = 64,
    this.background,
  });

  @override
  State<_CardPreviewOptimized> createState() => _CardPreviewOptimizedState();
}

class _CardPreviewOptimizedState extends State<_CardPreviewOptimized> {
  // ...existing code...
  @override
  Widget build(BuildContext context) {
    // TODO: Implement preview rendering logic
    return const SizedBox();
  }
}

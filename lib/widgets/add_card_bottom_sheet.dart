// ignore_for_file: library_private_types_in_public_api
// All imports must be at the very top
import 'dart:async';

import 'package:flutter/material.dart';

import '../config/preset_cards.dart';
import '../helpers/image_scan_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/camera_scan_page.dart';
import '../pages/image_scan_page.dart';
import '../utils/logo_helpers.dart';
import 'add_card_steps/add_card_bottom_actions.dart';
import 'add_card_steps/add_card_header.dart';
import 'add_card_steps/add_card_options.dart';
import 'add_card_steps/add_card_step_code_acquisition.dart';
import 'add_card_steps/add_card_step_details.dart';
import 'add_card_steps/add_card_step_preset.dart';
import 'add_card_steps/card_preview_optimized.dart';

class AddCardBottomSheet extends StatefulWidget {
  final Function(CardItem) onCardCreated;

  const AddCardBottomSheet({super.key, required this.onCardCreated});

  @override
  _AddCardBottomSheetState createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _codeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Trigger rebuild so buttons and previews update when controllers change
    if (mounted) setState(() {});
  }

  void _openLogoSelectionSheet(BuildContext context) {
    // TODO: Implement logo selection sheet logic or delegate to helper
  }

  // --- State fields ---
  final PageController _pageController = PageController();
  int _currentStep = 0;
  PresetCard? _selectedPreset;
  bool _isGenericSelected = false;
  bool _isTemporarySelected = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  CardType _cardType = CardType.qrCode;
  String? _logoPath;
  IconData? _selectedLogoIcon;
  bool _isTemporaryCard = false;
  int _temporaryDays = 7;
  final ValueNotifier<bool> _showManualEntry = ValueNotifier(false);

  // --- Method stubs for navigation and steps ---
  void _nextStep() {
    debugPrint(
      'AddCardBottomSheet: _nextStep called (currentStep=$_currentStep)',
    );
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
    });
    // Debugging: log page changes during tests
    debugPrint('AddCardBottomSheet: onPageChanged -> $page');
  }

  Widget _buildSecondaryOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Key? key,
  }) {
    return AddCardSecondaryOption(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
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
      return _selectedPreset != null ||
          _isGenericSelected ||
          _isTemporarySelected;
    } else if (step == 1) {
      return (_isGenericSelected || _isTemporarySelected)
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
    debugPrint('AddCardBottomSheet: _saveCard called');
    // Always try to set logoPath using helper, fallback to initials if not found
    String? logoPath;
    if (_selectedLogoIcon != null && _logoPath == null) {
      logoPath = getSimpleIconIdentifier(_selectedLogoIcon!);
    } else if (_logoPath != null) {
      logoPath = _logoPath;
    } else {
      logoPath = getLogoPathForTitle(_titleController.text.trim());
    }
    final newCard = CardItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      name: _codeController.text.trim(),
      cardType: _cardType,
      expiresAt:
          _isTemporaryCard
              ? DateTime.now().add(Duration(days: _temporaryDays))
              : null,
      logoPath: logoPath,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );
    widget.onCardCreated(newCard);
    if (mounted) {
      Navigator.of(context).pop(newCard);
    }
  }

  // Logo helpers moved to `lib/utils/logo_helpers.dart`

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _showManualEntry.dispose();
    super.dispose();
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
          // Header (progress + title)
          AddCardHeader(
            stepCounterText: AppLocalizations.of(
              context,
            ).stepCounter(_currentStep + 1, 3),
            stepTitle: _getStepTitle(),
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

          // Bottom actions (cancel/back/next/save)
          AddCardBottomActions(
            currentStep: _currentStep,
            canProceed: _canProceedFromStep(_currentStep),
            onCancel: () => Navigator.of(context).pop(),
            onBack:
                () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
            onNext: _nextStep,
            onSave: _saveCard,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelectionStep() {
    return AddCardStepPreset(
      selectedPreset: _selectedPreset,
      isGenericSelected: _isGenericSelected,
      isTemporarySelected: _isTemporarySelected,
      onPresetSelected: (preset) {
        setState(() {
          _selectedPreset = preset;
          _isGenericSelected = false;
          _isTemporarySelected = false;
          _isTemporaryCard = false;
        });
      },
      onGenericSelected: (selected) {
        setState(() {
          _selectedPreset = null;
          _isGenericSelected = selected;
          _isTemporarySelected = false;
          _isTemporaryCard = false;
        });
      },
      onTemporarySelected: (selected) {
        setState(() {
          _selectedPreset = null;
          _isGenericSelected = false;
          _isTemporarySelected = selected;
          _isTemporaryCard = selected;
          if (!selected) {
            _temporaryDays = 7;
          }
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
    return AddCardStepCodeAcquisition(
      codeController: _codeController,
      cardType: _cardType,
      onCardTypeChanged: (t) => setState(() => _cardType = t),
      showManualEntry: _showManualEntry,
      onScan: _startScan,
      onImageImport: _startImageImport,
      onManualEntry: _startManualEntry,
    );
  }

  Widget _buildCardDetailsStep() {
    return AddCardStepDetails(
      titleController: _titleController,
      descriptionController: _descriptionController,
      selectedLogoIcon: _selectedLogoIcon,
      isTemporary: _isTemporaryCard,
      temporaryDays: _temporaryDays,
      onLogoTap: () => _openLogoSelectionSheet(context),
      onTemporaryChanged: (value) {
        setState(() {
          _isTemporaryCard = value;
        });
      },
      onTemporaryDaysChanged: (value) {
        setState(() {
          _temporaryDays = value;
        });
      },
      shouldShowPreview: _shouldShowPreview(),
      previewWidget:
          _shouldShowPreview()
              ? CardPreviewOptimized(
                logoPath:
                    _selectedLogoIcon != null && _logoPath == null
                        ? getSimpleIconIdentifier(_selectedLogoIcon!)
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

/// Optimized preview widget that reduces rebuilds by caching values
// Preview widget extracted to `lib/widgets/add_card_steps/card_preview_optimized.dart`

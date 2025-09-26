import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../services/add_card_flow_manager.dart';
import '../services/error_handling_service.dart';
import '../services/logo_cache_service.dart';
import '../services/performance_monitoring_service.dart';
import '../widgets/logo_avatar_widget.dart';
import '../widgets/optimized_card_preview.dart';

/// Unified, performance-optimized add card widget
/// Consolidates all add card functionality with intelligent performance optimizations
class UnifiedAddCardWidget extends StatefulWidget {
  final Function(CardItem) onCardCreated;
  final AddCardFlowMode initialMode;
  final String? prefilledCode;
  final CardType? prefilledType;
  final bool showModeSelection;

  const UnifiedAddCardWidget({
    super.key,
    required this.onCardCreated,
    this.initialMode = AddCardFlowMode.selection,
    this.prefilledCode,
    this.prefilledType,
    this.showModeSelection = true,
  });

  @override
  State<UnifiedAddCardWidget> createState() => _UnifiedAddCardWidgetState();
}

class _UnifiedAddCardWidgetState extends State<UnifiedAddCardWidget> {
  final PageController _pageController = PageController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  AddCardFlowMode _currentMode = AddCardFlowMode.selection;
  CardType _cardType = CardType.qrCode;
  String? _logoPath;
  IconData? _selectedLogoIcon;
  bool _isLoading = false;
  int _currentStep = 0;

  // Performance optimization: debounce timer for logo suggestions
  Timer? _logoDebounceTimer;

  // Performance optimization: cache frequently used values
  String _lastTitleValue = '';
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _titleController.addListener(_onTitleChanged);
    _codeController.addListener(_onCodeChanged);

    if (widget.prefilledCode != null) {
      _codeController.text = widget.prefilledCode!;
    }
    if (widget.prefilledType != null) {
      _cardType = widget.prefilledType!;
    }

    PerformanceMonitoringService.instance.incrementCounter(
      'unified_add_card_opened',
    );
  }

  @override
  void dispose() {
    _logoDebounceTimer?.cancel();
    _titleController.removeListener(_onTitleChanged);
    _codeController.removeListener(_onCodeChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final currentValue = _titleController.text.trim();
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
    final canProceed = currentValue.isNotEmpty;

    if (_currentStep == 1 && _canProceed != canProceed) {
      setState(() {
        _canProceed = canProceed;
      });
    }
  }

  void _debouncedLogoSuggestion() {
    _logoDebounceTimer?.cancel();
    _logoDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted &&
          _selectedLogoIcon == null &&
          _titleController.text.trim().isNotEmpty) {
        _suggestLogoFromTitle();
      }
    });
  }

  Future<void> _suggestLogoFromTitle() async {
    try {
      final logoSuggestion = await LogoCacheService.instance.getSuggestedLogo(
        _titleController.text,
      );
      if (mounted && logoSuggestion != null && _selectedLogoIcon == null) {
        setState(() {
          _selectedLogoIcon = logoSuggestion;
        });
      }
    } catch (e) {
      ErrorHandlingService.instance.handleError(
        e,
        null,
        context: 'logo_suggestion',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (widget.showModeSelection && _currentStep == 0)
            _buildModeSelector(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [_buildCardDetailsStep(), _buildCodeInputStep()],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading:
          _currentStep > 0
              ? IconButton(
                onPressed: _previousStep,
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: theme.iconTheme.color,
                ),
              )
              : IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: theme.iconTheme.color),
              ),
      title: Text(
        _localStepTitle(context, _currentStep),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildModeSelector() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children:
            AddCardFlowMode.values
                .where((mode) => mode != AddCardFlowMode.selection)
                .map((mode) {
                  final isSelected = _currentMode == mode;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildModeButton(mode, isSelected),
                    ),
                  );
                })
                .toList(),
      ),
    );
  }

  Widget _buildModeButton(AddCardFlowMode mode, bool isSelected) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _currentMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mode.icon,
              size: 18,
              color: isSelected ? theme.colorScheme.onPrimary : theme.hintColor,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                mode.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview section - only show when meaningful content exists
          if (_shouldShowPreview()) ...[
            _buildPreviewSection(),
            const SizedBox(height: 24),
          ],

          // Form fields
          _buildFormFields(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).preview,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OptimizedCardPreview(
              logoPath: _logoPath,
              logoIcon: _selectedLogoIcon,
              title: _titleController.text,
              description: _descriptionController.text,
              logoSize: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          AppLocalizations.of(context).title + ' *',
          AppLocalizations.of(context).titleHint,
          _titleController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          AppLocalizations.of(context).description,
          AppLocalizations.of(context).optionalDescription,
          _descriptionController,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildLogoSection(),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).logoLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _openLogoSelection,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (_logoPath != null || _selectedLogoIcon != null) ...[
                  LogoAvatarWidget(
                    logoKey: _logoPath,
                    logoIcon: _selectedLogoIcon,
                    title: _titleController.text,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(AppLocalizations.of(context).logoSelected),
                  ),
                ] else ...[
                  Icon(
                    Icons.add_photo_alternate,
                    color: Theme.of(context).iconTheme.color?.withAlpha(153),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(AppLocalizations.of(context).selectALogo),
                  ),
                ],
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color?.withAlpha(153),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTypeSelector(),
          const SizedBox(height: 16),
          _buildCodeField(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).cardTypeLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // ignore: deprecated_member_use
        DropdownButtonFormField<CardType>(
          // ignore: deprecated_member_use
          value: _cardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          items:
              CardType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _cardType = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).code,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText:
                _cardType == CardType.qrCode
                    ? AppLocalizations.of(context).enterQrCodeValue
                    : AppLocalizations.of(context).enterBarcodeValue,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text(AppLocalizations.of(context).previous),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _canProceed && !_isLoading
                        ? (_currentStep == 1 ? _saveCard : _nextStep)
                        : null,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          _currentStep == 1
                              ? AppLocalizations.of(context).save
                              : AppLocalizations.of(context).next,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
      _canProceed =
          page == 0
              ? _titleController.text.trim().isNotEmpty
              : _codeController.text.trim().isNotEmpty;
    });
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

  void _nextStep() {
    if (_currentStep < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openLogoSelection() {
    // TODO: Implement logo selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).logoSelectionComingSoon),
      ),
    );
  }

  Future<void> _saveCard() async {
    if (!_canProceed) return;

    setState(() => _isLoading = true);

    try {
      final card = CardItem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        name: _codeController.text.trim(),
        cardType: _cardType,
        logoPath: _logoPath,
        sortOrder: DateTime.now().millisecondsSinceEpoch,
      );

      PerformanceMonitoringService.instance.incrementCounter(
        'unified_add_card_success',
      );
      widget.onCardCreated(card);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      PerformanceMonitoringService.instance.incrementCounter(
        'unified_add_card_error',
      );
      ErrorHandlingService.instance.handleError(
        e,
        stackTrace,
        context: 'save_card',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorSavingCard)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _localStepTitle(BuildContext context, int step) {
    final l = AppLocalizations.of(context);
    switch (step) {
      case 0:
        return l.cardDetails;
      case 1:
        return l.code;
      default:
        return l.addCard;
    }
  }
}

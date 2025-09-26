import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import '../l10n/app_localizations.dart';

import '../helpers/logo_helper.dart';
import '../models/card_item.dart';
import '../services/app_navigator.dart';
import '../widgets/card_preview_widget.dart';

class AddCardWizardPage extends StatefulWidget {
  const AddCardWizardPage({super.key});

  @override
  State<AddCardWizardPage> createState() => _AddCardWizardPageState();
}

class _AddCardWizardPageState extends State<AddCardWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers and state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  CardType _cardType = CardType.qrCode;
  String? _logoPath;
  IconData? _selectedLogoIcon;

  // Step titles are provided via localization at runtime.

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
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

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
    });

    // Auto-suggest logo when moving to step 2
    if (page == 1 && _selectedLogoIcon == null) {
      _suggestLogoFromTitle();
    }
  }

  Future<void> _suggestLogoFromTitle() async {
    if (_titleController.text.trim().isEmpty) return;

    final suggestion = await LogoHelper.suggestLogo(_titleController.text);
    if (suggestion != null && mounted) {
      setState(() {
        _selectedLogoIcon = suggestion;
      });
    }
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _titleController.text.trim().isNotEmpty;
      case 1:
        return true; // Logo is optional
      case 2:
        return _codeController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _saveCard() async {
    final logoPath =
        _selectedLogoIcon != null && _logoPath == null
            ? _getSimpleIconIdentifier(_selectedLogoIcon!)
            : _logoPath;

    final newCard = CardItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      name: _codeController.text.trim(),
      cardType: _cardType,
      logoPath: logoPath,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );

    if (mounted) {
      Navigator.of(context).pop(newCard);
    }
  }

  String? _getSimpleIconIdentifier(IconData icon) {
    final iconMap = {
      SimpleIcons.carrefour: 'simple_icon:carrefour',
      SimpleIcons.aldinord: 'simple_icon:aldinord',
      SimpleIcons.lidl: 'simple_icon:lidl',
      SimpleIcons.walmart: 'simple_icon:walmart',
      SimpleIcons.target: 'simple_icon:target',
      SimpleIcons.tesco: 'simple_icon:tesco',
      SimpleIcons.ikea: 'simple_icon:ikea',
      SimpleIcons.nike: 'simple_icon:nike',
      SimpleIcons.adidas: 'simple_icon:adidas',
      SimpleIcons.puma: 'simple_icon:puma',
      SimpleIcons.zara: 'simple_icon:zara',
      SimpleIcons.amazon: 'simple_icon:amazon',
      SimpleIcons.ebay: 'simple_icon:ebay',
      SimpleIcons.etsy: 'simple_icon:etsy',
      SimpleIcons.shopify: 'simple_icon:shopify',
      SimpleIcons.mcdonalds: 'simple_icon:mcdonalds',
      SimpleIcons.burgerking: 'simple_icon:burgerking',
      SimpleIcons.kfc: 'simple_icon:kfc',
      SimpleIcons.starbucks: 'simple_icon:starbucks',
      SimpleIcons.tacobell: 'simple_icon:tacobell',
    };
    return iconMap[icon];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStepTitle(context, _currentStep)),
        elevation: 0,
        actions: [
          if (_currentStep < 2)
            TextButton(
              onPressed: _canProceedFromStep(_currentStep) ? _nextStep : null,
              child: Text(AppLocalizations.of(context).next),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isCompleted || isActive
                              ? Theme.of(context).primaryColor
                              : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildBasicInfoStep(),
                _buildLogoSelectionStep(),
                _buildCodeAndPreviewStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text(AppLocalizations.of(context).previous),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _currentStep == 2
                            ? (_canProceedFromStep(_currentStep)
                                ? _saveCard
                                : null)
                            : (_canProceedFromStep(_currentStep)
                                ? _nextStep
                                : null),
                    child: Text(
                      _currentStep == 2
                          ? AppLocalizations.of(context).save
                          : AppLocalizations.of(context).next,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(BuildContext context, int step) {
    final l = AppLocalizations.of(context);
    switch (step) {
      case 0:
        return l.wizardStepBasicInfo;
      case 1:
        return l.wizardStepLogoSelection;
      case 2:
        return l.wizardStepCodeAndFinish;
      default:
        return '';
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geef je kaart een naam en omschrijving',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),

          _buildLabeledField(
            'Titel *',
            _titleController,
            'Naam van de winkel of service',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          _buildLabeledField(
            'Omschrijving',
            _descriptionController,
            'Extra details (bijv. lidmaatschapsnummer)',
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          Text(
            'Kaarttype',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CardType>(
                // ignore: deprecated_member_use
                value: _cardType,
                isExpanded: true,
                onChanged: (CardType? newValue) {
                  setState(() {
                    _cardType = newValue!;
                  });
                },
                items:
                    CardType.values.map<DropdownMenuItem<CardType>>((
                      CardType value,
                    ) {
                      return DropdownMenuItem<CardType>(
                        value: value,
                        child: Text(_getCardTypeDisplayName(value)),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kies een logo voor je kaart',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),

          // Current logo preview
          if (_selectedLogoIcon != null || _logoPath != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        _selectedLogoIcon != null
                            ? Icon(
                              _selectedLogoIcon,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                            : Icon(
                              Icons.image,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(200),
                            ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Geselecteerd Logo',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Logo selection options
          const Text(
            'Logo Opties',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Suggested logo (if available)
          if (_selectedLogoIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedLogoIcon,
                      size: 32,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aanbevolen Logo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          'Automatisch gevonden voor "${_titleController.text}"',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedLogoIcon = null),
                    icon: Icon(Icons.close, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.store),
              label: const Text('Zoek Merk Logo\'s'),
              onPressed: _openLogoSelectionSheet,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          if (_selectedLogoIcon != null || _logoPath != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Verwijder Logo',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed:
                    () => setState(() {
                      _selectedLogoIcon = null;
                      _logoPath = null;
                    }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeAndPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voer de code in en controleer je kaart',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),

          // Final preview
          CardPreviewWidget(
            logoPath:
                _selectedLogoIcon != null && _logoPath == null
                    ? _getSimpleIconIdentifier(_selectedLogoIcon!)
                    : _logoPath,
            title: _titleController.text,
            description: _descriptionController.text,
            logoSize: 80,
            background: Colors.white,
          ),
          const SizedBox(height: 24),

          // Code input
          _buildLabeledField(
            'Code *',
            _codeController,
            _cardType == CardType.qrCode
                ? 'QR code inhoud of URL'
                : 'Barcode nummer',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Code preview
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child:
                _codeController.text.trim().isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(200),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Code Voorbeeld',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Center(
                      child: Text(
                        'Code voorbeeld verschijnt hier',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(200),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(200),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            fillColor: theme.colorScheme.surface,
            filled: true,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  void _openLogoSelectionSheet() async {
    final selectedLogo = await AppNavigator.instance.pushLogoSelection(
      cardTitle: _titleController.text,
      currentLogo: _selectedLogoIcon,
    );

    if (selectedLogo != null) {
      setState(() {
        _selectedLogoIcon = selectedLogo;
        _logoPath = null;
      });
    }
  }

  String _getCardTypeDisplayName(CardType type) {
    switch (type) {
      case CardType.barcode:
        return 'Barcode';
      case CardType.qrCode:
        return 'QR Code';
    }
  }
}

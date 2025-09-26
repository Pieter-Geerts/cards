import 'package:flutter/material.dart';

import '../models/card_item.dart';
import '../widgets/card_preview_widget.dart';
import '../l10n/app_localizations.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _codeController;
  late CardType _selectedCardType;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _codeController = TextEditingController();
    _selectedCardType = CardType.barcode; // Default value
    _logoPath = null;
  }

  void saveChanges() {
    // Placeholder: persist changes
    Navigator.of(context).pop(
      CardItem(
        title: _titleController.text,
        description: _descriptionController.text,
        name: _codeController.text,
        cardType: _selectedCardType,
        logoPath: _logoPath,
        sortOrder: 0, // Default sort order
      ),
    );
  }

  // Extracted method to render the code visualization (barcode/QR)
  Widget _buildCodeVisualization() {
    return CardItem(
      title: _titleController.text,
      description: _descriptionController.text,
      name: _codeController.text,
      cardType: _selectedCardType,
      logoPath: _logoPath,
      sortOrder: 0,
    ).renderCode(
      size: _selectedCardType.is2D ? 160 : null,
      width: _selectedCardType.is1D ? 200 : null,
      height: _selectedCardType.is1D ? 80 : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context).addCard),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            tooltip: AppLocalizations.of(context).save,
            onPressed: saveChanges,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Preview Section
              CardPreviewWidget(
                logoPath: _logoPath,
                title: _titleController.text,
                description: _descriptionController.text,
                logoSize: 64,
                background: Colors.white,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.upload),
                    label: Text(AppLocalizations.of(context).uploadLogo),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      // TODO: implement image picker/camera
                    },
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      AppLocalizations.of(context).removeLogo,
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed:
                        _logoPath == null
                            ? null
                            : () => setState(() => _logoPath = null),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Card Details Section
              Text(
                AppLocalizations.of(context).cardDetails,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                AppLocalizations.of(context).title,
                _titleController,
                AppLocalizations.of(context).titleHint,
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                AppLocalizations.of(context).description,
                _descriptionController,
                AppLocalizations.of(context).descriptionHint,
                optional: true,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                AppLocalizations.of(context).cardTypeLabel,
                _selectedCardType,
                (val) {
                  if (val != null) setState(() => _selectedCardType = val);
                },
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                AppLocalizations.of(context).code,
                _codeController,
                AppLocalizations.of(context).codeValueLabel,
              ),
              const SizedBox(height: 28),
              // Code Visualization Section
              Text(
                AppLocalizations.of(context).codePreview,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(child: _buildCodeVisualization()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text(AppLocalizations.of(context).scanCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  // TODO: implement scan logic
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).save,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String hint, {
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            if (optional)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '(Optioneel)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    CardType value,
    ValueChanged<CardType?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<CardType>(
          // ignore: deprecated_member_use
          value: value,
          items:
              CardType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}

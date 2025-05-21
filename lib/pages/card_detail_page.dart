import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../helpers/database_helper.dart';
import '../models/card_item.dart';

class CardDetailPage extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onDelete;

  const CardDetailPage({super.key, required this.card, this.onDelete});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late CardItem _currentCard;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _titleController = TextEditingController(text: _currentCard.title);
    _descController = TextEditingController(text: _currentCard.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _deleteCard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.deleteCard),
            content: Text(l10n.deleteConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await DatabaseHelper().deleteCard(_currentCard.id!);
      widget.onDelete?.call(_currentCard);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentCard.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip:
                l10n.addCard, // Should be l10n.edit, but fallback if not present
            onPressed: _editing ? null : _startEditing,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: l10n.deleteCard,
            onPressed: () => _deleteCard(context),
          ),
        ],
      ),
      body:
          _editing
              ? _CardEditForm(
                card: _currentCard,
                onCancel: () {
                  setState(() {
                    _editing = false;
                  });
                },
                onSave: (updated) async {
                  await DatabaseHelper().updateCard(updated);
                  setState(() {
                    _currentCard = updated;
                    _editing = false;
                  });
                },
              )
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentCard.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_currentCard.description.isNotEmpty)
                      Text(
                        _currentCard.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.cardType(_currentCard.cardType),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: _buildCodeWidget(
                        MediaQuery.of(context).size.width * 0.7,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          tooltip: 'Share',
                          onPressed: () async {
                            final tempDir = await getTemporaryDirectory();
                            final file = File('${tempDir.path}/card.txt');
                            await file.writeAsString(_currentCard.name);
                            await Share.shareXFiles([
                              XFile(file.path),
                            ], text: _currentCard.title);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildCodeWidget(double availableWidth) {
    if (_currentCard.cardType == 'QR_CODE') {
      return QrImageView(
        data: _currentCard.name,
        size: availableWidth,
        backgroundColor: Colors.white,
      );
    } else {
      return BarcodeWidget(
        barcode: Barcode.code128(),
        data: _currentCard.name,
        width: availableWidth,
        height: 80,
        backgroundColor: Colors.white,
      );
    }
  }
}

class _CardEditForm extends StatefulWidget {
  final CardItem card;
  final void Function() onCancel;
  final void Function(CardItem updated) onSave;
  const _CardEditForm({
    required this.card,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_CardEditForm> createState() => _CardEditFormState();
}

class _CardEditFormState extends State<_CardEditForm> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _originalTitle;
  late String _originalDesc;
  bool _canSave = false;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _originalTitle = widget.card.title;
    _originalDesc = widget.card.description;
    _titleController = TextEditingController(text: _originalTitle);
    _descController = TextEditingController(text: _originalDesc);
    _titleController.addListener(_onChanged);
    _descController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _canSave =
          _titleController.text.trim() != _originalTitle.trim() ||
          _descController.text.trim() != _originalDesc.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.title,
                hintText: l10n.titleHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationTitleRequired;
                }
                if (value.trim().length < 3) {
                  return l10n.validationTitleMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionHint,
                border: const OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _canSave
                          ? () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSave(
                                widget.card.copyWith(
                                  title: _titleController.text.trim(),
                                  description: _descController.text.trim(),
                                ),
                              );
                            }
                          }
                          : null,
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

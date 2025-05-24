import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/card_item.dart';
import '../pages/home_page.dart' show buildLogoWidget;
import '../secrets.dart';
import '../services/logo_dev_service.dart';

class EditCardPage extends StatefulWidget {
  final CardItem card;
  final void Function(CardItem) onSave;

  const EditCardPage({super.key, required this.card, required this.onSave});

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _nameController;
  late LogoDevService _logoService;
  final TextEditingController _logoSearchController = TextEditingController();
  bool _isSearchingLogo = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descController = TextEditingController(text: widget.card.description);
    _nameController = TextEditingController(text: widget.card.name);
    _logoService = LogoDevService(logoDevApiKey);
    _logoPath = widget.card.logoPath;
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

  void _save() {
    final updatedCard = widget.card.copyWith(
      title: _titleController.text,
      description: _descController.text,
      name: _nameController.text,
      logoPath: _logoPath,
    );
    widget.onSave(updatedCard);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.edit),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.title),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: l10n.description),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company/Name'),
              ),
              const SizedBox(height: 16),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      leading: buildLogoWidget(result['logo_url']),
                      title: Text(result['name'] ?? ''),
                      subtitle: Text(result['domain'] ?? ''),
                      onTap:
                          () => _downloadAndSetLogo(
                            result['domain'] ?? result['name'] ?? '',
                          ),
                    );
                  },
                ),
              if (_logoPath != null && _logoPath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildLogoWidget(_logoPath),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

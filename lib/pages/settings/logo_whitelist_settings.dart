import 'package:flutter/material.dart';

import '../../services/logo_cache_service.dart';

class LogoWhitelistSettingsPage extends StatefulWidget {
  const LogoWhitelistSettingsPage({super.key});

  @override
  State<LogoWhitelistSettingsPage> createState() =>
      _LogoWhitelistSettingsPageState();
}

class _LogoWhitelistSettingsPageState extends State<LogoWhitelistSettingsPage> {
  final _controller = TextEditingController();
  late Set<String> _whitelist;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWhitelist();
  }

  Future<void> _loadWhitelist() async {
    // Ask the service to ensure loaded, so we see persisted or asset values
    await LogoCacheService.instance.reloadWhitelistFromAssets();
    setState(() {
      _whitelist = LogoCacheService.instance.getShopWhitelist();
      _loading = false;
    });
  }

  void _add() {
    final val = _controller.text.trim().toLowerCase();
    if (val.isEmpty) return;
    setState(() {
      _whitelist.add(val);
      _controller.clear();
    });
    LogoCacheService.instance.addShopToWhitelist(val);
  }

  void _remove(String item) {
    setState(() {
      _whitelist.remove(item);
    });
    LogoCacheService.instance.removeShopFromWhitelist(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logo whitelist')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Add shop identifier',
                              hintText: 'e.g. amazon',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _add,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children:
                            _whitelist
                                .toList()
                                .map(
                                  (e) => ListTile(
                                    title: Text(e),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _remove(e),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

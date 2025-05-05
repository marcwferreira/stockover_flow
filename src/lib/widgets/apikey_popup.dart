import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyPopup extends StatefulWidget {
  const ApiKeyPopup({super.key});

  @override
  State<ApiKeyPopup> createState() => _ApiKeyPopupState();
}

class _ApiKeyPopupState extends State<ApiKeyPopup> {
  final TextEditingController _apiKeyController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _saveApiKey() async {
    String apiKey = _apiKeyController.text;
    await _secureStorage.write(key: 'apiKey', value: apiKey);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome!',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('To use the app you\'ll need\nan Alpha Vantage API key!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saveApiKey,
          child: const Text('Finish',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _inputController = TextEditingController();
  late final ChatSession _session;
  final GenerativeModel _model = GenerativeModel(model: 'gemini-pro', apiKey: '<YOUR_API_KEY>');
  bool _loading = false;
  List<String> _summary = [];

  @override
  void initState() {
    super.initState();
    _session = _model.startChat();
    _loadSummary();
  }

  void _loadSummary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _summary = prefs.getStringList('summary') ?? [];
    });
  }

  void _saveSummary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('summary', _summary);
  }

  void _sendMessage() async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await _session.sendMessage(Content.text(_inputController.text));
      var text = response.text;

      if (text != null) {
        setState(() {
          _summary.add('User: ${_inputController.text}');
          _summary.add('AI: $text');
          if (_summary.length > 4) {
            _summary.removeRange(0, 2); // Keep only the last two exchanges
          }
          _saveSummary();
        });
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _inputController.clear();
      setState(() {
        _loading = false);
      });
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: _summary.map((message) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(message),
                    const SizedBox(height: 10.0),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                _loading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

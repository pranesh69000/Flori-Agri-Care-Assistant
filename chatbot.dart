import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'chat_history_screen.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  Map<String, String> _chatResponses = {};
  bool _isOnline = true;

  final String geminiApiKey = ''; // Replace with your actual key

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    loadChatResponses();
    loadSavedMessages();
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> loadChatResponses() async {
    final String response = await rootBundle.loadString('assets/chatbot_responses.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      _chatResponses = data.map((key, value) => MapEntry(key.toLowerCase(), value.toString()));
    });
  }

  Future<void> loadSavedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('chat_history');
    if (saved != null) {
      setState(() {
        _messages = List<Map<String, String>>.from(
          (json.decode(saved) as List).map((item) => Map<String, String>.from(item)),
        );
      });
    }
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', json.encode(_messages));
  }

  Future<String> getGeminiResponseOrFallback(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$geminiApiKey',
    );
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            _chatResponses[prompt.toLowerCase()] ??
            "மன்னிக்கவும், எனக்கு புரியவில்லை.\nSorry, I don't understand.";
      } else {
        return _chatResponses[prompt.toLowerCase()] ??
            "மன்னிக்கவும், எனக்கு புரியவில்லை.\nSorry, I don't understand.";
      }
    } catch (e) {
      return _chatResponses[prompt.toLowerCase()] ??
          "மன்னிக்கவும், எனக்கு புரியவில்லை.\nSorry, I don't understand.";
    }
  }

  Future<void> simulateTypingEffect(String fullText) async {
    String botTypingText = '';
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 30));
      botTypingText += fullText[i];
      setState(() {
        _messages[_messages.length - 1]['message'] = botTypingText;
      });
    }
  }

  void handleSendMessage() async {
    await checkConnectivity();

    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "message": userMessage});
      _controller.clear();
    });

    setState(() {
      _messages.add({"sender": "bot", "message": "Typing..."});
    });

    await Future.delayed(Duration(seconds: 2));

    String botReply = await getGeminiResponseOrFallback(userMessage);

    await simulateTypingEffect(botReply);
    await saveMessages();
  }

  Future<void> downloadChatAsPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => _messages.map((m) {
          return pw.Text("${m['sender']?.toUpperCase()}: ${m['message']}");
        }).toList(),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_history.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat saved as PDF in ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flori-Agri Chatbot'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: downloadChatAsPdf,
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Container(
                  padding: EdgeInsets.all(10),
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user' ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(message['message'] ?? ""),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "உங்களின் கேள்வியை உள்ளிடவும் / Ask your question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (_) => handleSendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


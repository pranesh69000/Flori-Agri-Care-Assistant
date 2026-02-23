import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryScreen extends StatefulWidget {
  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    loadSavedMessages();
  }

  Future<void> loadSavedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('chat_history');
    if (saved != null) {
      final List<dynamic> decoded = json.decode(saved);
      final List<Map<String, String>> messages = decoded.map<Map<String, String>>((item) {
        return {
          'sender': item['sender'].toString(),
          'message': item['message'].toString(),
        };
      }).toList();

      setState(() {
        _messages = messages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Chat History")),
      body: _messages.isEmpty
          ? Center(child: Text("No chat history found."))
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text("${message['sender']?.toUpperCase()}"),
            subtitle: Text(message['message'] ?? ""),
          );
        },
      ),
    );
  }
}

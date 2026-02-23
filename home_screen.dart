import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:floriagri/screens/camera.dart';
import 'package:floriagri/screens/gallery.dart';
import 'package:floriagri/screens/chatbot.dart';
import 'package:floriagri/screens/chat_history_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FLORI AGRI CARE ASSISTANT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3), // Optional overlay for better readability
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'WELCOME TO FLORI AGRI CARE ASSISTANT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildButton(context, 'Detect disease using camera ', const CameraScreen()),
                  //const SizedBox(height: 20),
                  //_buildButton(context, 'Upload from Gallery', const Gallery()),
                  const SizedBox(height: 20),
                  _buildButton(context, 'Ask Crop/Flower Questions (Chatbot)', ChatbotScreen()),
                  const SizedBox(height: 20),
                  _buildButton(context, 'View Previous Chat Answers', ChatHistoryScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(label),
    );
  }
}

// ✅ Gallery screen placeholder
class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Detection'),
        backgroundColor: Colors.green[800],
      ),
      body: const Center(
        child: Text(
          'Gallery detection feature coming soon...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

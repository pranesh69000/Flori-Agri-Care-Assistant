import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class GalleryDetectionScreen extends StatefulWidget {
  const GalleryDetectionScreen({super.key});

  @override
  State<GalleryDetectionScreen> createState() => _GalleryDetectionScreenState();
}

class _GalleryDetectionScreenState extends State<GalleryDetectionScreen> {
  late FlutterVision vision;
  List<Map<String, dynamic>> results = [];
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    initModel();
  }

  Future<void> initModel() async {
    vision = FlutterVision();
    await vision.loadYoloModel(
      labels: 'assets/CLASSES.txt',
      modelPath: 'assets/best_float32.tflite',
      modelVersion: 'yolov8',
      useGpu: false,
      numThreads: 2,
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return;

    File image = File(imageFile.path);
    final Uint8List imageBytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to decode image")),
      );
      return;
    }

    final result = await vision.yoloOnImage(
      bytesList: imageBytes, // FIXED: pass Uint8List, not List<Uint8List>
      imageHeight: decodedImage.height,
      imageWidth: decodedImage.width,
      iouThreshold: 0.4,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );

    setState(() {
      selectedImage = image;
      results = result;
    });
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gallery Detection")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Select Image from Gallery"),
            ),
            const SizedBox(height: 20),
            if (selectedImage != null) ...[
              Image.file(selectedImage!, height: 300),
              const SizedBox(height: 10),
              ...results.map((res) => Text(
                "${res['tag']} ${(res['score'] * 100).toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 18),
              ))
            ]
          ],
        ),
      ),
    );
  }
}

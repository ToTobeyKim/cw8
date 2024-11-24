import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageLabelingScreen extends StatefulWidget {
  @override
  _ImageLabelingScreenState createState() => _ImageLabelingScreenState();
}

class _ImageLabelingScreenState extends State<ImageLabelingScreen> {
  File? _image; // Holds the selected image
  List<String> _labels = []; // List of detected labels
  final ImagePicker _picker = ImagePicker(); // For selecting images

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _labels = []; // Clear previous labels
      });
      _labelImage(_image!); // Label the new image
    }
  }

  Future<void> _labelImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();

    try {
      final List<ImageLabel> detectedLabels = await imageLabeler.processImage(inputImage);

      setState(() {
        _labels = detectedLabels.map((label) {
          return "${label.label} (${(label.confidence * 100).toStringAsFixed(2)}%)";
        }).toList();
      });
    } catch (e) {
      print("Error in labeling image: $e");
    } finally {
      imageLabeler.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Camera'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Gallery'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _labels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_labels[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

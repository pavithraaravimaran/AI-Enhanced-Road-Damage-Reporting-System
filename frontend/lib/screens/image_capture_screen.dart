import 'dart:io';
import 'dart:convert';  // For encoding image to Base64
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final User? user = FirebaseAuth.instance.currentUser;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _landmarkController = TextEditingController();

  // Pick image using the camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Send image to Flask API for processing
  Future<String> _processImage(File image) async {
    // Convert the image to Base64
    final bytes = await image.readAsBytes();
    String base64Image = base64Encode(bytes);

    // API URL for Flask
    final apiUrl = 'http://172.18.72.219:5000/upload'; // Replace with your Flask server URL

    // Create the request payload
    final Map<String, dynamic> requestData = {
      'image': base64Image,
      'markerType': 'BOX', // Or 'MARK' depending on your needs
    };

    // Send the image to the Flask API
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(requestData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['processed_image']; // Assuming Flask returns processed image filename
    } else {
      throw Exception('Failed to process image');
    }
  }

  // Upload processed image to Firebase Storage
  Future<void> _uploadImage(String processedImageFileName) async {
    if (_imageFile == null || user == null) return;

    // Create a reference to the processed image in Firebase Storage
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(user!.uid)
        .child(processedImageFileName);

    UploadTask uploadTask = storageRef.putFile(_imageFile!);

    // Wait for the upload to finish
    TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL of the uploaded image
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    // Save the download URL and description to Firestore under the user's collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('reports')
        .add({
      'imageUrl': downloadUrl,
      'description': _descriptionController.text,  // Store description
      'landmark': _landmarkController.text,       // Store landmark
      'uploadedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display image
            if (_imageFile != null)
              Center(
                child: Image.file(
                  _imageFile!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),

            // Description input field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),

            // Landmark input field
            TextField(
              controller: _landmarkController,
              decoration: InputDecoration(
                labelText: 'Enter Landmark',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            SizedBox(height: 20),

            // Capture Image button
            ElevatedButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Capture Image'),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),

            // Upload Image button
            if (_imageFile != null)
              ElevatedButton(
                onPressed: () async {
                  try {
                    String processedImageFileName = await _processImage(_imageFile!);
                    await _uploadImage(processedImageFileName);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to process or upload image: $e')),
                    );
                  }
                },
                child: Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

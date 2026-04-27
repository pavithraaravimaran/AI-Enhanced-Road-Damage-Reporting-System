import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final User? user = FirebaseAuth.instance.currentUser;

  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadReport() async {
    if (_imageFile == null || user == null) return;

    String description = _descriptionController.text.trim();
    String landmark = _landmarkController.text.trim();

    if (description.isEmpty || landmark.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    // Create a unique file name for the image
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('user_reports')
        .child(user!.uid)
        .child(fileName);

    UploadTask uploadTask = storageRef.putFile(_imageFile!);

    // Wait for upload to finish
    TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL of the uploaded image
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    // Save the report details to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('reports')
        .add({
      'imageUrl': downloadUrl,
      'description': description,
      'landmark': landmark,
      'uploadedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report submitted successfully!')),
    );

    // Clear the form after submission
    _descriptionController.clear();
    _landmarkController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Damage Report'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Capture Image'),
              onPressed: _pickImage,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description of Damage',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _landmarkController,
              decoration: InputDecoration(
                labelText: 'Landmark',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (_imageFile != null)
              ElevatedButton(
                onPressed: _uploadReport,
                child: Text('Submit Report'),
              ),
          ],
        ),
      ),
    );
  }
}
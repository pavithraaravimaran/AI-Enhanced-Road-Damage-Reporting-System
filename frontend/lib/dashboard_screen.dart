import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_capture_screen.dart'; // Make sure this is imported

class DashboardScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<String>> _getUserImages() async {
    if (user == null) return [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('images')
        .get();

    return querySnapshot.docs.map((doc) => doc['imageUrl'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Road Damage Detector',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<String>>(
        future: _getUserImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No images found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final images = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the ImageCaptureScreen when button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImageCaptureScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        tooltip: 'Capture Image',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

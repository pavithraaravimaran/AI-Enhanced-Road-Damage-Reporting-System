import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart'; // Import ReportModel class

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user ID
  String getCurrentUserId() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  // Stream to fetch reports for the current user as a list of ReportModel
  Stream<List<ReportModel>> getReports() {
    String userId = getCurrentUserId();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reports')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReportModel(
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          landmark: data['landmark'] ?? '',
          uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),  // Convert Timestamp to DateTime
        );
      }).toList();
    });
  }

  // Upload report to Firestore and Firebase Storage
  Future<void> uploadReport({
    required XFile image,
    required String description,
    required String landmark,
  }) async {
    try {
      String userId = getCurrentUserId();

      // Create file path and upload image to Firebase Storage
      String filePath = 'reports/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(File(image.path));
      String downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save the report details in Firestore under the user's reports collection
      await _firestore.collection('users').doc(userId).collection('reports').add({
        'imageUrl': downloadUrl,
        'description': description,
        'landmark': landmark,
        'uploadedAt': DateTime.now(),  // Store as DateTime
      });
    } catch (e) {
      print('Error uploading report: $e');
      throw e;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String imageUrl;
  final String description;
  final String landmark;
  final DateTime uploadedAt;  // Updated to DateTime

  ReportModel({
    required this.imageUrl,
    required this.description,
    required this.landmark,
    required this.uploadedAt,
  });

  factory ReportModel.fromFirestore(Map<String, dynamic> data) {
    return ReportModel(
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      landmark: data['landmark'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),  // Convert Timestamp to DateTime
    );
  }
}

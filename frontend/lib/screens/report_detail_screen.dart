import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
      ),
      body: Container(
        color: Colors.white,  // Use white or any desired background color
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(report.imageUrl),
            SizedBox(height: 16),
            Text(
              report.landmark,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(report.description),
            SizedBox(height: 16),
            Text(
              'Uploaded at: ${DateFormat('yyyy-MM-dd HH:mm').format(report.uploadedAt.toLocal())}',
            ),
          ],
        ),
      ),
    );
  }
}

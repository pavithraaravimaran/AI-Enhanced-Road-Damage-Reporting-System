import 'package:flutter/material.dart';
import '../models/report_model.dart';

class ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  const ReportCard({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(report['imageUrl'], width: 100, height: 100),
        title: Text(report['description']),
        subtitle: Text('Landmark: ${report['landmark']}'),
      ),
    );
  }
}

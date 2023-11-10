import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> drugData;

  DetailPage({Key? key, required this.drugData}) : super(key: key);
  String safeAccess(List<dynamic>? list) {
    if (list != null && list.isNotEmpty) {
      return list.first;
    }
    return 'Information not available';
  }

  @override
  Widget build(BuildContext context) {
    final String brandName = safeAccess(drugData['openfda']?['brand_name']);
    final String description = safeAccess(drugData['indications_and_usage']);
    final String patientInformation =
        safeAccess(drugData['patient_medication_information']);
    final String warnings = safeAccess(drugData['warnings']);
    final String uses = safeAccess(drugData['indications_and_usage']);
    final bool isControlledSubstance = drugData['controlled_substance'] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(brandName),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            title: const Text('Description'),
            subtitle: Text(description),
          ),
          ListTile(
            title: const Text('Patient Information'),
            subtitle: Text(patientInformation),
          ),
          ListTile(
            title: const Text('Warnings'),
            subtitle: Text(warnings),
          ),
          ListTile(
            title: const Text('Uses'),
            subtitle: Text(uses),
          ),
          ListTile(
            title: const Text('Controlled Medication'),
            subtitle: Text(isControlledSubstance ? 'Yes' : 'No'),
          ),
        ],
      ),
    );
  }
}

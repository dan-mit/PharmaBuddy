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
    final theme = Theme.of(context);
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
          Card(
            child: ListTile(
              title: Text('Description', style: theme.textTheme.titleMedium),
              subtitle: Text(description),
              leading: Icon(Icons.description, color: theme.primaryColor),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Patient Information',
                  style: theme.textTheme.titleMedium),
              subtitle: Text(patientInformation),
              leading: Icon(Icons.person, color: theme.primaryColor),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Warnings', style: theme.textTheme.titleMedium),
              subtitle: Text(warnings),
              leading: Icon(Icons.warning, color: theme.primaryColor),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Uses', style: theme.textTheme.titleMedium),
              subtitle: Text(uses),
              leading:
                  Icon(Icons.question_mark_rounded, color: theme.primaryColor),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Controlled Substance?',
                  style: theme.textTheme.titleMedium),
              subtitle: Text(isControlledSubstance ? 'Yes' : 'No'),
              leading:
                  Icon(Icons.local_police_rounded, color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

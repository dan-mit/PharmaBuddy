import 'package:flutter/material.dart';
import 'package:pharmabuddy/models/drug_provider.dart';
import 'package:provider/provider.dart';
import 'package:pharmabuddy/models/drug.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var drugList = Provider.of<DrugProvider>(context).drugList;
    return Scaffold(
      appBar: AppBar(title: Text('My Dashboard')),
      body: drugList.isEmpty
          ? Center(child: Text('No Drugs Scheduled'))
          : ListView.builder(
              itemCount: drugList.length,
              itemBuilder: (context, index) {
                Drug drug = drugList[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.all(4),
                  child: ListTile(
                    title: Text(drug.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dosage: ${drug.dosage}'),
                        Text('Days: ${getWeekdaysFromBooleans(drug.days)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        DrugProvider drugProvider =
                            Provider.of<DrugProvider>(context, listen: false);
                        drugProvider.removeDrug(drugList[index]);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

String getWeekdaysFromBooleans(List<bool> days) {
  List<String> dayNames = ['M', 'T', 'W', 'Th', 'F', 'S', 'S'];

  Iterable<String> selectedDays = days
      .asMap()
      .entries
      .where((entry) => entry.value)
      .map((entry) => dayNames[entry.key]);

  return selectedDays.join(', ');
}

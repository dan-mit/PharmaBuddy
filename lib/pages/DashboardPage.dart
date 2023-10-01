import 'package:flutter/material.dart';
import 'package:pharmabuddy/models/drug_provider.dart';
import 'package:provider/provider.dart';
import 'package:pharmabuddy/models/drug.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //create the lsit display of drugs, this will be put into database when made
    var drugList = Provider.of<DrugProvider>(context).drugList;
    return Scaffold(
        appBar: AppBar(title: Text('My Dashboard')),
        body: drugList.isEmpty
            ? Center(child: Text('No Drugs Scheduled'))
            : ListView.builder(
                itemCount: drugList.length,
                itemBuilder: (context, index) {
                  Drug drug = drugList[index];
                  return ListTile(
                    title: Text(drug.name),
                    subtitle: Text('Dosage: ${drug.dosage}'),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        DrugProvider drugProvider =
                            Provider.of<DrugProvider>(context, listen: false);
                        drugProvider.removeDrug(drugList[index]);
                      },
                    ),
                  );
                }));
  }
}

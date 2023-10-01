import 'package:flutter/foundation.dart';
import 'package:pharmabuddy/models/drug.dart';

/* The drug provider models is the management model for my drug data
This allows for CRUD operations by other compenents in the app,
not just the schedule page */

class DrugProvider with ChangeNotifier {
  List<Drug> _drugList = [];

  List<Drug> get drugList => _drugList;

  void addDrug(Drug drug) {
    _drugList.add(drug);
    notifyListeners();
  }

  void removeDrug(Drug drug) {
    _drugList.remove(drug);
    notifyListeners();
  }
}

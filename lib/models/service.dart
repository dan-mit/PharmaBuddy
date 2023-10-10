import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> searchDrug(String query) async {
    //API Url
    final url = Uri.parse(
        'https://api.fda.gov/drug/label.json?search=openfda.brand_name:"$query"&limit=5');
    //API call
    final response = await http.get(url);
    //API Response handling
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load API data');
    }
  }
}

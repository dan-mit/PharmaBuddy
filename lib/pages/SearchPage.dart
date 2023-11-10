import 'package:flutter/material.dart';
import 'package:pharmabuddy/models/service.dart';
import 'package:pharmabuddy/pages/DetailPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ApiService drugSearch = ApiService();
  String query = "";
  List<dynamic> searchResults = [];

  void search() async {
    try {
      final results = await drugSearch.searchDrug(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  String safeGetValue(Map<String, dynamic> map, String key, [int index = 0]) {
    // Check if the key exists in the map and is non-null, otherwise return a default value
    if (map[key] != null && map[key] is List && map[key].length > index) {
      return map[key][index] ?? 'No Data Available';
    } else {
      return 'No Data Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Drug')),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                query = value;
              });
              if (query.isNotEmpty) {
                search();
              }
            },
            decoration: InputDecoration(
              labelText: 'Search for a Drug',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var drug = searchResults[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(drugData: drug),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                          safeGetValue(drug['openfda'] ?? {}, 'brand_name')),
                      subtitle:
                          Text(safeGetValue(drug, 'indications_and_usage')),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

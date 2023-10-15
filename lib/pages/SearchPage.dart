import 'package:flutter/material.dart';
import 'package:pharmabuddy/models/service.dart';

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
        SnackBar(content: Text('Error: $e')),
      );
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
                  child: ListTile(
                    title: Text(drug['openfda']['brand_name'][0] ??
                        'No Name Available'),
                    subtitle: Text(drug['indications_and_usage'][0] ??
                        'No Description Available'),
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

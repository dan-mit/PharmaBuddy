import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Place>> fetchPharmacies(double latitude, double longitude) async {
  final apiKey = '';
  final response = await http.get(
    Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=pharmacy&key=$apiKey'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<Place> pharmacies = [];
    for (var place in data['results']) {
      pharmacies.add(Place.fromJson(place));
    }
    return pharmacies;
  } else {
    throw Exception('Failed to load pharmacies');
  }
}

class Place {
  final String name;
  final String address;
  final double lat;
  final double lng;

  Place(
      {required this.name,
      required this.address,
      required this.lat,
      required this.lng});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['vicinity'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_webservice/places.dart' as gmaps;

class LocatePage extends StatefulWidget {
  @override
  _LocatePageState createState() => _LocatePageState();
}

class _LocatePageState extends State<LocatePage> {
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final gmaps.GoogleMapsPlaces places = gmaps.GoogleMapsPlaces(apiKey: "");

  @override
  void initState() {
    super.initState();
    initializeLocation();
  }

  void initializeLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    loadPharmacies(); // Load pharmacies and place markers on the map
  }

  void loadPharmacies() async {
    if (_locationData != null) {
      final location = gmaps.Location(
          lat: _locationData!.latitude!, lng: _locationData!.longitude!);
      final result =
          await places.searchNearbyWithRadius(location, 1000, type: "pharmacy");

      if (result.status == "OK") {
        setState(() {
          _markers.clear();
          for (var place in result.results) {
            _markers.add(
              Marker(
                markerId: MarkerId(place.id ?? 'default_id'),
                position: LatLng(
                    place.geometry!.location.lat, place.geometry!.location.lng),
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet: place.vicinity,
                ),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locationData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Locate Pharmacies'),
        actions: [
          IconButton(
              onPressed: () async {
                String? address = await showSearchDialog(context);
                if (address != null && address.isNotEmpty) {
                  _searchAddress(address);
                }
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          zoom: 14.0,
        ),
        markers: _markers,
      ),
    );
  }

  Future<void> _searchAddress(String address) async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final result = locations.first;
        _goToLocation(result.latitude, result.longitude);
      }
    } on Exception catch (e) {
      print('Failed to find location: $e');
    }
  }

  void _goToLocation(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 14),
    ));
  }

  Future<String?> showSearchDialog(BuildContext context) async {
    String? userInput;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Address or Zip Code'),
          content: TextField(
            onChanged: (value) {
              userInput = value;
            },
            decoration: const InputDecoration(hintText: "Search here..."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                Navigator.of(context).pop(userInput);
              },
            ),
          ],
        );
      },
    );
  }
}

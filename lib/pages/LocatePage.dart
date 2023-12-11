import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:pharmabuddy/models/pharmacyLocate.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeLocation();
    });
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
      try {
        final pharmacies = await fetchPharmacies(
            _locationData!.latitude!, _locationData!.longitude!);
        setState(() {
          _markers.clear();
          for (var pharmacy in pharmacies) {
            _markers.add(
              Marker(
                markerId: MarkerId(pharmacy.name),
                position: LatLng(pharmacy.lat, pharmacy.lng),
                infoWindow: InfoWindow(
                  title: pharmacy.name,
                  snippet:
                      '${pharmacy.address}\nPhone: ${pharmacy.phoneNumber}',
                ),
              ),
            );
          }
        });
      } catch (e) {
        print('Error fetching pharmacies: $e');
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

  Future<void> _goToLocation(double lat, double lng) async {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 14),
    ));
    try {
      final pharmacies = await fetchPharmacies(lat, lng);
      setState(() {
        _markers.clear();
        for (var pharmacy in pharmacies) {
          _markers.add(
            Marker(
              markerId: MarkerId(pharmacy.name),
              position: LatLng(pharmacy.lat, pharmacy.lng),
              infoWindow: InfoWindow(
                title: pharmacy.name,
                snippet: pharmacy.address,
              ),
            ),
          );
        }
      });
    } catch (e) {
      // Handle errors here
      print('Error fetching pharmacies: $e');
    }
  }

  Future<String?> showSearchDialog(BuildContext context) async {
    String? userInput;

    bool isValidZipCode(String? input) {
      final zipCodePattern =
          RegExp(r'^\d{5}$'); // Regex pattern for a 5-digit zip code
      return input != null && zipCodePattern.hasMatch(input);
    }

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter zip code to find pharmacies in the area'),
          content: TextField(
            onChanged: (value) {
              userInput = value;
            },
            decoration: const InputDecoration(hintText: "Zip Code"),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                if (isValidZipCode(userInput)) {
                  Navigator.of(context).pop(userInput);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

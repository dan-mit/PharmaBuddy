import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

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

  void loadPharmacies() {
    // Load pharmacies and update state
    // This should ideally be fetched from a database or API
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('pharmacy1'),
          position: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          infoWindow: InfoWindow(
              title: 'Pharmacy Name', snippet: 'Address, Phone Number'),
        ),
      );
    });
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
}

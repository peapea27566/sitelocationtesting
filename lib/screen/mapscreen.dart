import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;

import 'siteListScreen.dart';
import '../model/placePrediction.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(13.736717, 100.523186);
  final TextEditingController _searchController = TextEditingController();
  Prediction? _selectedPrediction;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=AIzaSyAAE7gJaMl9TuL_wvsVbza3HBZKDiDkDhQ';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      var predictions =
          json.decode(response.body)['predictions'] as List<dynamic>;
      setState(() {
        _selectedPrediction = null; // Clear previous selection
        _searchController.clear(); // Clear the search field
      });

      if (predictions.isNotEmpty) {
        Prediction firstPrediction = Prediction.fromJson(predictions.first);
        _moveToPlace(firstPrediction);
      }
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<void> _moveToPlace(Prediction prediction) async {
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    String request =
        '$placeDetailsUrl?place_id=${prediction.placeId}&fields=name,geometry&key=AIzaSyAAE7gJaMl9TuL_wvsVbza3HBZKDiDkDhQ';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      var placeDetails = json.decode(response.body)['result'];
      double lat = placeDetails['geometry']['location']['lat'];
      double lng = placeDetails['geometry']['location']['lng'];

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
      );
      prediction.lat = lat;
      prediction.lng = lng;

      setState(() {
        _selectedPrediction = prediction;
      });
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      if (_selectedPrediction != null) {
        _selectedPrediction = Prediction(
            lat: latLng.latitude,
            lng: latLng.longitude,
            description: "${latLng.latitude},${latLng.longitude}",
            placeId: _selectedPrediction!.placeId,
            matchedSubstrings: _selectedPrediction!.matchedSubstrings,
            reference: _selectedPrediction!.reference,
            structuredFormatting: _selectedPrediction!.structuredFormatting,
            terms: _selectedPrediction!.terms,
            types: _selectedPrediction!.types);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกที่อยู่ส่งด่วน', style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold)),
        centerTitle: true,
        shadowColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [googleMap(), fieldSearchLocation()],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cardAddress(),
                const SizedBox(height: 16.0),
                btnConfirmLocation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget googleMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 15.0,
      ),
      onTap: _onMapTap,
      markers: _selectedPrediction != null
          ? {
              Marker(
                markerId: MarkerId(_selectedPrediction!.placeId),
                position: LatLng(
                  _selectedPrediction!.lat,
                  _selectedPrediction!.lng,
                ),
              ),
            }
          : {},
    );
  }

  Widget fieldSearchLocation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: TextField(
          controller: TextEditingController(),
          decoration: InputDecoration(
            hintText: 'ค้นหาที่อยู่จัดส่งสินค้า',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchPlaces(
                  value); // Uncomment and define this method if needed
            }
          },
        ),
      ),
    );
  }

  Widget cardAddress() {
    return Card(
        elevation: 4.0,
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ที่อยู่* (ตำบล, อำเภอ, จังหวัด, รหัสไปรษณีย์)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _selectedPrediction?.description != null
                                ? _selectedPrediction!.description
                                : "กรุณาเลือก พิกัด",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const Icon(Icons.my_location, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget btnConfirmLocation() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () {
            if (_selectedPrediction != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SiteListScreen(
                    coordinatesSelected: [
                      _selectedPrediction!.lat,
                      _selectedPrediction!.lng,
                    ],
                  ),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Please select a location'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
            // Define your onPressed functionality here
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            // Text color
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 15.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded corners
            ),
          ),
          child: const Text('ยืนยันตำแหน่ง')),
    );
  }
}

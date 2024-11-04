import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  LocationData? currentLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];

  final String orsApiKey =
      '5b3ce3597851110001cf6248706aec7fc0164552bc691a86843fbed0';

  @override
  
void initState() {
  super.initState();
  _checkLocationPermission().then((_) => _getCurrentLocation());
}
Future<void> _checkLocationPermission() async {
  var location = Location();
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return; // Service non activé
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return; // Permission refusée
  }
}


  Future<void> _getCurrentLocation() async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            builder: (ctx) => const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 40.0,
            ),
          ),
        );
      });
   debugPrint('Localisation actuelle: ${userLocation.latitude}, ${userLocation.longitude}');
  } catch (e) {
    debugPrint('Erreur de localisation: $e');
  }

    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
      });
    });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (currentLocation == null) return;

    final start =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    final response = await http.get(
      Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey'
        '&start=${start.longitude},${start.latitude}'
        '&end=${destination.longitude},${destination.latitude}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: destination,
            builder: (ctx) => const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
      });
    } else {
      debugPrint('Failed to fetch route');
    }
  }

  void _addDestinationMarker(LatLng point) {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          builder: (ctx) => const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    });
    _getRoute(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte'),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
  center: LatLng(33.8869, 9.5375), // Coordonnées approximatives de la Tunisie
  zoom: 7.0, // Zoom initial pour voir tout le pays
  onTap: (tapPosition, point) => _addDestinationMarker(point),
),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: markers,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentLocation != null) {
            mapController.move(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              15.0,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MappScreen extends StatefulWidget {
  const MappScreen({Key? key}) : super(key: key); // Ajout du paramètre `key`

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MappScreen> {
  LatLng? currentLocation;
  LatLng? destinationLocation;
  final MapController _mapController = MapController();

  final TextEditingController _currentPlaceController = TextEditingController();
  final TextEditingController _destPlaceController = TextEditingController();

  // Fonction pour obtenir les coordonnées d'un lieu à partir de Nominatim
  Future<LatLng?> _getCoordinatesFromPlace(String place) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$place&format=json&limit=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lng = double.parse(data[0]['lon']);
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  void _zoomToLocation(LatLng location) {
    _mapController.move(location, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un trajet par nom de lieu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _currentPlaceController,
                    decoration: const InputDecoration(
                      labelText: 'Lieu actuel',
                      hintText: 'Ex: Café des Délices, Tunis',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _destPlaceController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      hintText: 'Ex: Rue Habib Bourguiba, Sfax',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPlace = _currentPlaceController.text;
              final destPlace = _destPlaceController.text;

              if (currentPlace.isNotEmpty && destPlace.isNotEmpty) {
                LatLng? currentCoords =
                    await _getCoordinatesFromPlace(currentPlace);
                LatLng? destCoords =
                    await _getCoordinatesFromPlace(destPlace);

                if (!mounted) return; // Vérification de `mounted`

                if (currentCoords != null && destCoords != null) {
                  setState(() {
                    currentLocation = currentCoords;
                    destinationLocation = destCoords;
                  });
                  _zoomToLocation(destCoords);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('L\'un des lieux est introuvable.')),
                  );
                }
              }
            },
            child: const Text('Afficher le trajet'),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(33.8869, 9.5375), // Centre de la Tunisie
                zoom: 6.0, // Zoom initial
                minZoom: 6.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  tileSize: 256,
                  maxZoom: 18,
                ),
                if (currentLocation != null && destinationLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: currentLocation!,
                        builder: (context) => const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: destinationLocation!,
                        builder: (context) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                if (currentLocation != null && destinationLocation != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [currentLocation!, destinationLocation!],
                        strokeWidth: 4.0,
                        color: Colors.green,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

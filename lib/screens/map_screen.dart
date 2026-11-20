import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/park_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = const LatLng(4.6583, -74.0939); // Coordenada inicial
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocationAndParks();
  }

  Future<void> _initLocationAndParks() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final Position pos = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }

    final parks = await ParkService.fetchNearbyParks(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );

    if (!mounted) return;
    setState(() {
      _markers.clear();
      for (int i = 0; i < parks.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('park_$i'),
            position: LatLng(parks[i]['lat'], parks[i]['lon']),
            infoWindow: InfoWindow(
              title: parks[i]['name'],
              snippet: 'Zona verde cercana',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
      _isLoading = false;
    });
  }

  // === Esta parte se corta en el PDF de la guía: la completé con widgets básicos ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parques Cercanos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}


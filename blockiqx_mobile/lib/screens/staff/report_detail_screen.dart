import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../models/report.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late LatLng _incidentLocation;
  LatLng? _userLocation;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();

    if (widget.report.latitude == null || widget.report.longitude == null) {
      throw Exception("Invalid coordinates");
    }

    _incidentLocation = LatLng(
      widget.report.latitude!,
      widget.report.longitude!,
    );

    _init();
  }

  Future<void> _init() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showPermissionDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      _userLocation = LatLng(position.latitude, position.longitude);

      _setMarkers();
      await _createPolyline();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Enable location permission from settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  void _setMarkers() {
    _markers.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId("incident"),
        position: _incidentLocation,
        infoWindow: const InfoWindow(title: "Incident"),
      ),
    );

    if (_userLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("user"),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: "You"),
        ),
      );
    }

    setState(() {});
  }

  Future<void> _createPolyline() async {
    if (_userLocation == null) return;

    /// ✅ Correct for latest package (v3.x)
    PolylinePoints polylinePoints =
        PolylinePoints(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          _userLocation!.latitude,
          _userLocation!.longitude,
        ),
        destination: PointLatLng(
          _incidentLocation.latitude,
          _incidentLocation.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> coords =
          result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

      setState(() {
        _polylines.clear();

        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: coords,
            width: 5,
            color: Colors.blue,
          ),
        );
      });
    }
  }

  void _toggleMaximized() {
    setState(() {
      _isMaximized = !_isMaximized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Details")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _incidentLocation,
              zoom: 14,
            ),
            onMapCreated: (c) => _controller.complete(c),
            markers: _markers,
            polylines: _polylines,
          ),
          if (!_isMaximized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Location Details",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text("Address: ${widget.report.location}"),
                      const SizedBox(height: 8),
                      Text(
                        "${_incidentLocation.latitude.toStringAsFixed(5)}, "
                        "${_incidentLocation.longitude.toStringAsFixed(5)}",
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _toggleMaximized,
                        icon: const Icon(Icons.directions),
                        label: const Text("Get Directions"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isMaximized
          ? FloatingActionButton(
              onPressed: _toggleMaximized,
              child: const Icon(Icons.close),
            )
          : null,
    );
  }
}

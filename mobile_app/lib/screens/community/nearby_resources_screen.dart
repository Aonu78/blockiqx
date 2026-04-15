import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class NearbyResourcesScreen extends StatefulWidget {
  const NearbyResourcesScreen({super.key});

  @override
  State<NearbyResourcesScreen> createState() => _NearbyResourcesScreenState();
}

class _NearbyResourcesScreenState extends State<NearbyResourcesScreen> {
  List<dynamic> _resources = [];
  bool _loading = true;
  String? _error;
  double? _lat, _lng;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final perm = await Geolocator.checkPermission();
      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        _lat = pos.latitude;
        _lng = pos.longitude;
      }
    } catch (_) {}

    final token = context.read<AuthProvider>().token ?? '';
    try {
      final results =
          await ApiService.getNearbyResources(token, lat: _lat, lng: _lng);
      setState(() {
        _resources = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Nearby Resources',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchResources,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchResources,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _resources.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_outlined,
                              size: 56, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No nearby resources found',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _resources.length,
                      itemBuilder: (_, i) {
                        final r = _resources[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43A047).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.place,
                                  color: Color(0xFF43A047)),
                            ),
                            title: Text(
                              r['name']?.toString() ?? 'Resource',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: r['location'] != null
                                ? Text(r['location'].toString())
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crscl/features/repair_centers/repair_center_repository.dart';
import 'package:crscl/features/repair_centers/models/repair_center.dart';

class RepairCentersMapScreen extends StatefulWidget {
  const RepairCentersMapScreen({super.key});

  @override
  _RepairCentersMapScreenState createState() => _RepairCentersMapScreenState();
}

class _RepairCentersMapScreenState extends State<RepairCentersMapScreen> {
  final RepairCenterRepository _repository = RepairCenterRepository();
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(0, 0); // Default initial position
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRepairCenters();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchRepairCenters() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      List<RepairCenter> repairCenters = await _repository.fetchRepairCenters();
      if (!mounted) return;
      setState(() {
        _markers.clear();
        for (var repairCenter in repairCenters) {
          _markers.add(Marker(
            markerId: MarkerId(repairCenter.id),
            position: repairCenter.location,
            infoWindow: InfoWindow(title: repairCenter.name),
          ));
        }
        if (repairCenters.isNotEmpty) {
          _initialPosition = repairCenters.first.location;
        }
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching repair centers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Centers Map'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        markers: _markers,
      ),
    );
  }
}

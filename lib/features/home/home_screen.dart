import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../repair_centers/models/repair_center.dart';
import '../repair_centers/repositories/repair_center_repository.dart';
import '../repair_centers/widgets/service_center_card.dart';
import '../repair_centers/widgets/service_center_list_tile.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _user = Supabase.instance.client.auth.currentUser;
  final _searchController = TextEditingController();
  final _serviceCenterRepository = RepairCenterRepository();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _center = const LatLng(45.521563, -122.677433); // Default center
  List<RepairCenter> _serviceCenters = [];
  bool _isLoading = true;
  bool _isMapView = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadServiceCenters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
      if (mounted && _mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _center, zoom: 15),
          ),
        );
      }
    } catch (e) {
      // Handle location errors
    }
  }

  Future<void> _loadServiceCenters() async {
    setState(() => _isLoading = true);
    try {
      final centers = await _serviceCenterRepository.getNearbyRepairCenters(
        userLocation: _center,
        radius: 10.0, // 10km radius
      );
      setState(() {
        _serviceCenters = centers;
        _markers.clear();
        for (var center in centers) {
          _markers.add(
            Marker(
              markerId: MarkerId(center.id),
              position: center.location,
              infoWindow: InfoWindow(
                title: center.name,
                snippet:
                    '⭐ ${center.rating} · ${center.isOpen ? 'Open' : 'Closed'}',
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/service-center-details',
                      arguments: center,
                    ),
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading service centers: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _searchServiceCenters(String query) async {
    if (query.isEmpty) {
      _loadServiceCenters();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final centers = await _serviceCenterRepository.getNearbyRepairCenters(
        userLocation: _center,
        searchQuery: query,
      );
      setState(() {
        _serviceCenters = centers;
        _markers.clear();
        for (var center in centers) {
          _markers.add(
            Marker(
              markerId: MarkerId(center.id),
              position: center.location,
              infoWindow: InfoWindow(
                title: center.name,
                snippet:
                    '⭐ ${center.rating} · ${center.isOpen ? 'Open' : 'Closed'}',
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/service-center-details',
                      arguments: center,
                    ),
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching service centers: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('CRSCL'),
            const SizedBox(width: 8),
            if (_user != null && _user.email != null)
              Expanded(
                child: Text(
                  _user.email!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for services or locations',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: _searchServiceCenters,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isMapView ? Icons.list : Icons.map),
                  onPressed: () => setState(() => _isMapView = !_isMapView),
                  tooltip: _isMapView ? 'Show List View' : 'Show Map View',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Show filter options
                  },
                  tooltip: 'Filter Results',
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_isMapView)
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                  if (_serviceCenters.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 160,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _serviceCenters.length,
                          itemBuilder: (context, index) {
                            final center = _serviceCenters[index];
                            return ServiceCenterCard(
                              serviceCenter: center,
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/service-center-details',
                                    arguments: center,
                                  ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _serviceCenters.length,
                itemBuilder: (context, index) {
                  final center = _serviceCenters[index];
                  return ServiceCenterListTile(
                    serviceCenter: center,
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/service-center-details',
                          arguments: center,
                        ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/appointments');
              break;
            case 2:
              Navigator.pushNamed(context, '/chat-list');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

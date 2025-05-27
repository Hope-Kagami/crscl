import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/repair_center.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RepairCenterRepository {
  final SupabaseClient _client;

  RepairCenterRepository() : _client = Supabase.instance.client;

  Future<List<RepairCenter>> getNearbyRepairCenters({
    required LatLng userLocation,
    String? searchQuery,
    double radius = 50.0, // in kilometers
  }) async {
    try {
      final response = await _client.rpc(
        'get_nearby_repair_centers',
        params: {
          'p_latitude': userLocation.latitude,
          'p_longitude': userLocation.longitude,
          'p_radius': radius,
          'p_search_query': searchQuery,
        },
      );

      return (response as List)
          .map((json) => RepairCenter.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load repair centers: $e');
    }
  }

  Future<RepairCenter> getRepairCenterDetails(String id) async {
    try {
      final response =
          await _client.from('repair_centers').select().eq('id', id).single();
      return RepairCenter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load repair center details: $e');
    }
  }
}

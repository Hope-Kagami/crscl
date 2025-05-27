import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_center.dart';

class ServiceCenterRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceCenter>> getServiceCenters({
    String? searchQuery,
    double? latitude,
    double? longitude,
    double? radius, // in kilometers
  }) async {
    try {
      var query = _supabase.from('service_centers').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.textSearch('name', searchQuery);
      }

      if (latitude != null && longitude != null && radius != null) {
        // Using PostGIS to calculate distance and filter by radius
        final response = await _supabase.rpc(
          'nearby_service_centers',
          params: {'lat': latitude, 'lng': longitude, 'radius_km': radius},
        );
        return (response as List)
            .map((json) => ServiceCenter.fromJson(json))
            .toList();
      }

      final response = await query;
      return (response as List)
          .map((json) => ServiceCenter.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load service centers: $e');
    }
  }

  Future<ServiceCenter> getServiceCenterById(String id) async {
    try {
      final response =
          await _supabase
              .from('service_centers')
              .select()
              .eq('id', id)
              .single();
      return ServiceCenter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load service center: $e');
    }
  }

  Future<List<ServiceCenter>> searchServiceCenters(String query) async {
    try {
      final response = await _supabase
          .from('service_centers')
          .select()
          .textSearch('name', query)
          .order('rating', ascending: false);
      return (response as List)
          .map((json) => ServiceCenter.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search service centers: $e');
    }
  }
}

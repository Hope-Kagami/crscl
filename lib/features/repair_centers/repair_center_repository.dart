import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crscl/features/repair_centers/models/repair_center.dart';

class RepairCenterRepository {
  final SupabaseClient _supabase;

  RepairCenterRepository() : _supabase = Supabase.instance.client;
  Future<List<RepairCenter>> getServiceCenters({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      // Using PostGIS's ST_DWithin to find repair centers within radius km
      final response = await _supabase.rpc(
        'get_repair_centers_within_radius',
        params: {
          'ref_lat': latitude,
          'ref_lon': longitude,
          'radius_km': radius,
        },
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => RepairCenter.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch repair centers: $e');
    }
  }

  Future<List<RepairCenter>> searchServiceCenters(String query) async {
    try {
      final response = await _supabase
          .from('repair_centers')
          .select()
          .or('name.ilike.%$query%,services.cs.{$query}')
          .order('rating', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => RepairCenter.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search repair centers: $e');
    }
  }

  Future<RepairCenter?> getRepairCenterById(String id) async {
    try {
      final response =
          await _supabase.from('repair_centers').select().eq('id', id).single();

      return RepairCenter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch repair center details: $e');
    }
  }
}

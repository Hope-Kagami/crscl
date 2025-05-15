import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crscl/features/repair_centers/models/repair_center.dart';

class RepairCenterRepository {
  final SupabaseClient _supabase;

  RepairCenterRepository() : _supabase = Supabase.instance.client;

  Future<List<RepairCenter>> fetchRepairCenters() async {
    try {
      final response = await _supabase.from('repair_centers').select('*');
      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => RepairCenter.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch repair centers: $e');
    }
  }

  Future<List<RepairCenter>> searchRepairCenters(String query) async {
    try {
      final response = await _supabase
          .from('repair_centers')
          .select('*')
          .ilike('name', '%$query%');
      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => RepairCenter.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search repair centers: $e');
    }
  }
}

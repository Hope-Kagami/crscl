import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRepository {
  final SupabaseClient _supabase;

  AppointmentRepository() : _supabase = Supabase.instance.client;

  Future<void> createAppointment({
    required String repairCenterId,
    required String userId,
    required DateTime dateTime,
    required String description,
  }) async {
    try {
      await _supabase.from('appointments').insert({
        'repair_center_id': repairCenterId,
        'user_id': userId,
        'date_time': dateTime.toIso8601String(),
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }
}

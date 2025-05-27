import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRepository {
  final SupabaseClient _client;

  AppointmentRepository() : _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserAppointments() async {
    try {
      final response = await _client.from('appointments').select();
      return response;
    } catch (error) {
      throw Exception('Failed to load appointments: $error');
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await _client.from('appointments').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to cancel appointment: $error');
    }
  }
}

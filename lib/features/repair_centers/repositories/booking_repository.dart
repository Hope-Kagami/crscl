import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository() : _supabase = Supabase.instance.client;

  Future<List<DateTime>> getAvailableTimeSlots({
    required String repairCenterId,
    required DateTime date,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_available_time_slots',
        params: {
          'repair_center_id': repairCenterId,
          'date_to_check': date.toIso8601String().split('T')[0],
        },
      );

      final List<dynamic> slots = response as List<dynamic>;
      return slots.map((slot) {
        final parts = (slot as String).split(':');
        return DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch available time slots: $e');
    }
  }

  Future<void> createBooking({
    required String repairCenterId,
    required String userId,
    required DateTime appointmentDateTime,
    required String description,
    List<String> services = const [],
  }) async {
    try {
      await _supabase.from('appointments').insert({
        'repair_center_id': repairCenterId,
        'user_id': userId,
        'appointment_date': appointmentDateTime.toIso8601String().split('T')[0],
        'appointment_time': appointmentDateTime
            .toIso8601String()
            .split('T')[1]
            .substring(0, 5),
        'description': description,
        'services': services,
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('''
            *,
            repair_centers (
              name,
              address,
              phone_number
            )
          ''')
          .eq('user_id', userId)
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class ServiceHistoryRepository {
  final _supabase = Supabase.instance.client;
  final _logger = Logger();

  Future<List<Map<String, dynamic>>> getServiceHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _logger.i('Fetching service history for user: $userId');

      final response = await _supabase
          .from('service_history')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.e('Error fetching service history: ${e.toString()}\n$stackTrace');
      throw Exception('Failed to fetch service history: ${e.toString()}');
    }
  }

  Future<void> addServiceRecord({
    required String serviceType,
    required DateTime completedAt,
    required String status,
    String? notes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _logger.i('Adding new service record for user: $userId');

      await _supabase.from('service_history').insert({
        'user_id': userId,
        'service_type': serviceType,
        'completed_at': completedAt.toIso8601String(),
        'status': status,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });

      _logger.i('Service record added successfully');
    } catch (e, stackTrace) {
      _logger.e('Error adding service record: ${e.toString()}\n$stackTrace');
      throw Exception('Failed to add service record: ${e.toString()}');
    }
  }

  Future<void> updateServiceRecord({
    required String recordId,
    String? serviceType,
    DateTime? completedAt,
    String? status,
    String? notes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _logger.i('Updating service record: $recordId');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (serviceType != null) updates['service_type'] = serviceType;
      if (completedAt != null) {
        updates['completed_at'] = completedAt.toIso8601String();
      }
      if (status != null) updates['status'] = status;
      if (notes != null) updates['notes'] = notes;

      await _supabase
          .from('service_history')
          .update(updates)
          .eq('id', recordId)
          .eq('user_id', userId);

      _logger.i('Service record updated successfully');
    } catch (e, stackTrace) {
      _logger.e('Error updating service record: ${e.toString()}\n$stackTrace');
      throw Exception('Failed to update service record: ${e.toString()}');
    }
  }

  Future<void> deleteServiceRecord(String recordId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _logger.i('Deleting service record: $recordId');

      await _supabase
          .from('service_history')
          .delete()
          .eq('id', recordId)
          .eq('user_id', userId);

      _logger.i('Service record deleted successfully');
    } catch (e, stackTrace) {
      _logger.e('Error deleting service record: ${e.toString()}\n$stackTrace');
      throw Exception('Failed to delete service record: ${e.toString()}');
    }
  }
}

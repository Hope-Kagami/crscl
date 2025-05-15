import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRepository {
  final SupabaseClient _supabase;

  ReviewRepository() : _supabase = Supabase.instance.client;

  Future<void> submitReview({
    required String repairCenterId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'repair_center_id': repairCenterId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }
}

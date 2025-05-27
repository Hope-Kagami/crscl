import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response =
        await _client.from('profiles').select().eq('id', userId).single();

    return response;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('profiles').upsert({'id': userId, ...data});
  }
}

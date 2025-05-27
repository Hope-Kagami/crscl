import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepository {
  final _client = Supabase.instance.client;

  Future<void> processPayment(Map<String, dynamic> paymentData) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.rpc(
      'process_payment',
      params: {
        'user_id': userId,
        'amount': paymentData['amount'],
        'currency': paymentData['currency'],
        'payment_method': paymentData['paymentMethodId'],
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    return await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}

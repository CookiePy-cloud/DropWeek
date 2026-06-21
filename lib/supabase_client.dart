import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static const String _url = 'https://gyfshzdvmevyzvseitcx.supabase.co';
  static const String _anonKey = 'sb_publishable_qL16qaPXweYQ2q1Hcx5lSw_kaRTptyw';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      publishableKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

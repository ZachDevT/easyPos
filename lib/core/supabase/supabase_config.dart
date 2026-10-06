import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'REPLACE_WITH_YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'REPLACE_WITH_YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    // Only initialize if keys are provided to avoid crashing the offline app
    if (supabaseUrl != 'REPLACE_WITH_YOUR_SUPABASE_URL') {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
  }

  static SupabaseClient? get client {
    if (supabaseUrl == 'REPLACE_WITH_YOUR_SUPABASE_URL') return null;
    return Supabase.instance.client;
  }
}

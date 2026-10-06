import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://uretwlyfrucmtihkdsww.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVyZXR3bHlmcnVjbXRpaGtkc3d3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNzgwNTIsImV4cCI6MjEwNjg1NDA1Mn0.XoXM8imEbMref3OWihK9kcr9yWJdJo3htq53ebdfgiA';

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

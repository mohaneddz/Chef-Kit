import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

/// Lightweight singleton wrapper around Supabase client.
///
/// Reads from either dart-define or .env:
/// - SUPABASE_URL
/// - SUPABASE_ANON_KEY
class SupabaseManager {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client != null) return _client!;

    final url = _readConfig('SUPABASE_URL');
    final key = _readConfig('SUPABASE_ANON_KEY');
    if (url.isEmpty || key.isEmpty) {
      throw StateError(
        'Supabase config missing. Set SUPABASE_URL and SUPABASE_ANON_KEY '
        'via --dart-define or .env',
      );
    }

    _client = SupabaseClient(url, key);
    return _client!;
  }

  static String _readConfig(String name) {
    final fromDefine = String.fromEnvironment(name).trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromEnv = (dotenv.env[name] ?? '').trim();
    return fromEnv;
  }
}



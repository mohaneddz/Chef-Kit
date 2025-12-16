import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // `String.fromEnvironment` reads compile-time Dart defines (e.g. `--dart-define`).
  // `dotenv.env[...]` reads from the runtime-loaded `.env` file (via flutter_dotenv).
  static String get baseUrl {
    const fromDefine = String.fromEnvironment('BASE_URL');
    final defineValue = fromDefine.trim();
    if (defineValue.isNotEmpty) return defineValue;

    final dotenvValue = (dotenv.env['BASE_URL'] ?? '').trim();
    if (dotenvValue.isNotEmpty) return dotenvValue;

    throw StateError(
      'BASE_URL is not configured.\n'
      '- Option A: flutter run --dart-define=BASE_URL=https://<your-backend>\n'
      '- Option B: create a .env file with BASE_URL=... (kept out of git)\n',
    );
  }
}

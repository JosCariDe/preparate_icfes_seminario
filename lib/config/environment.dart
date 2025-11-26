import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['API_URL'] ?? 'MOCK';
      }
      return 'MOCK';
    } catch (e) {
      // If dotenv is not initialized, return MOCK
      return 'MOCK';
    }
  }

  static bool get isMock {
    return apiUrl == 'MOCK' || apiUrl.isEmpty;
  }

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // If .env file doesn't exist, we'll just use defaults (MOCK)
      print('No .env file found, using mock data');
    }
  }
}

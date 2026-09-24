/// Application-wide configuration, read from compile-time defines.
///
/// Values come from `frontend/.env` (see `.env.example`):
/// `flutter run -d chrome --dart-define-from-file=.env`
///
/// A single value can also be overridden inline:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/api`
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5001/api',
  );
}

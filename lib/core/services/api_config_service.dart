import "package:get_storage/get_storage.dart";
import "../constants/storage_keys.dart";

class ApiConfigService {
  static const String defaultBaseUrl = "http://localhost:5002";

  final GetStorage _storage = GetStorage();

  String _normalizeBaseUrl(String value) {
    var normalized = value.trim().replaceAll(RegExp(r"/+$"), "");

    if (normalized.endsWith("/api")) {
      normalized = normalized.substring(0, normalized.length - 4);
    }

    return normalized;
  }

  String get baseUrl {
    final stored = _storage.read<String>(StorageKeys.apiBaseUrl);
    return _normalizeBaseUrl(stored ?? defaultBaseUrl);
  }

  Future<void> setBaseUrl(String value) async {
    final normalized = _normalizeBaseUrl(value);
    await _storage.write(StorageKeys.apiBaseUrl, normalized);
  }
}

import "dart:convert";
import "package:http/http.dart" as http;
import "package:get_storage/get_storage.dart";
import "../constants/storage_keys.dart";
import "../services/api_config_service.dart";

class ApiClient {
  final ApiConfigService _apiConfigService;
  final GetStorage _storage = GetStorage();

  ApiClient(this._apiConfigService);

  Uri _uri(String endpoint) => Uri.parse("${_apiConfigService.baseUrl}$endpoint");

  Map<String, String> _buildHeaders({bool withAuth = false}) {
    final headers = <String, String>{"Content-Type": "application/json"};

    if (withAuth) {
      final token = _storage.read<String>(StorageKeys.authAccessToken);
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return headers;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) {
    return http.post(
      _uri(endpoint),
      headers: _buildHeaders(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> get(String endpoint, {bool withAuth = false}) {
    return http.get(
      _uri(endpoint),
      headers: _buildHeaders(withAuth: withAuth),
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) {
    return http.patch(
      _uri(endpoint),
      headers: _buildHeaders(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = false}) {
    return http.delete(
      _uri(endpoint),
      headers: _buildHeaders(withAuth: withAuth),
    );
  }
}

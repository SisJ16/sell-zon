import "dart:convert";
import "package:get_storage/get_storage.dart";
import "../../../core/constants/storage_keys.dart";
import "../../../core/network/api_client.dart";
import "../../../core/network/api_endpoints.dart";
import "../models/auth_user.dart";

class AuthService {
  final GetStorage _storage = GetStorage();
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  AuthUser? getSessionUser() {
    final sessionData = _storage.read(StorageKeys.authSession);
    if (sessionData is Map) {
      return AuthUser.fromJson(Map<String, dynamic>.from(sessionData));
    }
    return null;
  }

  String? get accessToken => _storage.read<String>(StorageKeys.authAccessToken);

  String? get refreshToken => _storage.read<String>(StorageKeys.authRefreshToken);

  Exception _extractError(dynamic response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return Exception(decoded["message"] ?? "Request failed");
    } catch (_) {
      return Exception("Request failed (${response.statusCode})");
    }
  }

  AuthUser _extractUser(Map<String, dynamic> payload) {
    final userJson = Map<String, dynamic>.from(payload["user"] as Map);
    return AuthUser(
      id: userJson["id"] as String? ?? "",
      name: userJson["name"] as String? ?? "",
      email: userJson["email"] as String? ?? "",
      role: userJson["role"] as String? ?? "customer",
    );
  }

  Future<void> _saveSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(StorageKeys.authSession, user.toJson());
    await _storage.write(StorageKeys.authAccessToken, accessToken);
    await _storage.write(StorageKeys.authRefreshToken, refreshToken);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.auth.register,
      body: {
        "name": name.trim(),
        "email": email.trim().toLowerCase(),
        "password": password,
      },
    );

    if (response.statusCode != 201) {
      throw _extractError(response);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(decoded["data"] as Map);
    final user = _extractUser(data);

    await _saveSession(
      user: user,
      accessToken: data["accessToken"] as String? ?? "",
      refreshToken: data["refreshToken"] as String? ?? "",
    );

    return user;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.auth.login,
      body: {
        "email": email.trim().toLowerCase(),
        "password": password,
      },
    );

    if (response.statusCode != 200) {
      throw _extractError(response);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(decoded["data"] as Map);
    final user = _extractUser(data);

    await _saveSession(
      user: user,
      accessToken: data["accessToken"] as String? ?? "",
      refreshToken: data["refreshToken"] as String? ?? "",
    );

    return user;
  }

  Future<void> refreshSession() async {
    final token = refreshToken;
    if (token == null || token.isEmpty) {
      throw Exception("No refresh token found");
    }

    final response = await _apiClient.post(
      ApiEndpoints.auth.refresh,
      body: {"refreshToken": token},
    );

    if (response.statusCode != 200) {
      throw _extractError(response);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(decoded["data"] as Map);
    final user = _extractUser(data);

    await _saveSession(
      user: user,
      accessToken: data["accessToken"] as String? ?? "",
      refreshToken: data["refreshToken"] as String? ?? "",
    );
  }

  Future<void> logout() async {
    final token = refreshToken;
    if (token != null && token.isNotEmpty) {
      await _apiClient.post(
        ApiEndpoints.auth.logout,
        body: {"refreshToken": token},
      );
    }

    await _storage.remove(StorageKeys.authSession);
    await _storage.remove(StorageKeys.authAccessToken);
    await _storage.remove(StorageKeys.authRefreshToken);
  }
}

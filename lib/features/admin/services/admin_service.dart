import "dart:convert";
import "../../../core/network/api_client.dart";
import "../../../core/network/api_endpoints.dart";
import "../models/admin_user.dart";

class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  Exception _extractError(dynamic response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return Exception(decoded["message"] ?? "Request failed");
    } catch (_) {
      return Exception("Request failed (${response.statusCode})");
    }
  }

  Future<List<AdminUser>> fetchUsers({String search = ""}) async {
    final query = search.trim().isEmpty ? "" : "?search=${Uri.encodeQueryComponent(search.trim())}";
    final response = await _apiClient.get("${ApiEndpoints.admin.users}$query", withAuth: true);

    if (response.statusCode != 200) {
      throw _extractError(response);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(decoded["data"] as Map);
    final items = (data["items"] as List<dynamic>? ?? [])
        .map((item) => AdminUser.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return items;
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.admin.updateRole(userId),
      withAuth: true,
      body: {"role": role},
    );

    if (response.statusCode != 200) {
      throw _extractError(response);
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await _apiClient.delete(ApiEndpoints.admin.userById(userId), withAuth: true);

    if (response.statusCode != 200) {
      throw _extractError(response);
    }
  }
}

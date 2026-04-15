import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/models/address_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AddressController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoints.addresses.list, withAuth: true);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = decoded["data"] as List<dynamic>? ?? [];
        addresses.assignAll(
          items
              .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList(),
        );
      }
    } catch (_) {
      // no-op
    } finally {
      isLoading.value = false;
    }
  }

  Future<AddressModel?> createAddress({
    required String label,
    required String fullAddress,
    required String note,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addresses.create,
        withAuth: true,
        body: {
          "label": label,
          "fullAddress": fullAddress,
          "note": note,
          "latitude": latitude,
          "longitude": longitude,
          "isDefault": isDefault,
        },
      );
      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final address = AddressModel.fromJson(
          Map<String, dynamic>.from(decoded["data"] as Map),
        );
        await fetchAddresses();
        return address;
      }
    } catch (_) {
      // no-op
    }
    return null;
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.addresses.delete(id), withAuth: true);
      await fetchAddresses();
    } catch (_) {
      // no-op
    }
  }
}

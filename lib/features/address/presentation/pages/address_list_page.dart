import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/address_controller.dart';
import 'add_address_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressController _addressController = Get.find<AddressController>();

  Future<void> _openMapAndAddAddress() async {
    final selectedAddress = await Get.to<String>(() => const AddAddressPage());
    if (selectedAddress != null && selectedAddress.trim().isNotEmpty) {
      Get.snackbar(
        "Added",
        "New address saved",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_addressController.isLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ..._addressController.addresses.map(
              (address) => GestureDetector(
                onTap: () => Get.back(result: "[${address.label}] ${address.fullAddress}"),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "[${address.label}] ${address.fullAddress}${address.note.isEmpty ? "" : "\nNote: ${address.note}"}",
                        ),
                      ),
                      IconButton(
                        onPressed: () => _addressController.deleteAddress(address.id),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _openMapAndAddAddress,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Center(
                  child: Text("Add New Address"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

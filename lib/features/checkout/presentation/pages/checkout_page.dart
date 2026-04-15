import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../address/controllers/address_controller.dart';
import '../../../address/presentation/pages/add_address_page.dart';
import '../../../../core/models/address_model.dart';
import '../../../../core/models/payment_method_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../home/controllers/home_controller.dart';
import 'order_tracking_page.dart';
import 'payment_process_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color _storeGreen = Color(0xFF22C55E);
  static const Color _blue = Color(0xFF2196F3);
  static const Color _blueLight = Color(0xFFE3F2FD);

  String selectedAddressId = "";
  String selectedPayment = "";
  bool isPaymentLoading = false;
  final paymentMethods = <PaymentMethodModel>[];

  final AddressController _addressController = Get.find<AddressController>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  double get subtotal => Get.find<HomeController>().totalPrice;
  double get tax => subtotal * 0.02;
  double get deliveryCharge => 2.99;
  double get discount => subtotal >= 100 ? 5.0 : 0;
  double get total => subtotal + tax + deliveryCharge - discount;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _addressController.fetchAddresses();
  }

  String _extractMessage(String body, {String fallback = "Request failed"}) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return (decoded["message"] ?? fallback).toString();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => isPaymentLoading = true);
    try {
      final response = await _apiClient.get(ApiEndpoints.payments.methods, withAuth: true);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = decoded["data"] as List<dynamic>? ?? [];
        paymentMethods
          ..clear()
          ..addAll(
            items
                .map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList(),
          );
        if (paymentMethods.isNotEmpty && selectedPayment.isEmpty) {
          selectedPayment = paymentMethods.first.id;
        }
      } else {
        Get.snackbar("Payment", _extractMessage(response.body));
      }
    } catch (_) {
      Get.snackbar("Payment", "Failed to load payment methods");
    } finally {
      if (mounted) setState(() => isPaymentLoading = false);
    }
  }

  Future<void> _pickAddress() async {
    final result = await Get.to<String>(() => const AddAddressPage());
    if (result != null && result.trim().isNotEmpty) {
      await _addressController.fetchAddresses();
      if (_addressController.addresses.isNotEmpty) {
        setState(() => selectedAddressId = _addressController.addresses.first.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Get.back(),
          color: Colors.black87,
        ),
        title: const Text(
          "Shipping Information",
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deliveryAddressSection(),
            const SizedBox(height: 20),
            _promoCard(),
            const SizedBox(height: 20),
            _instantPaymentCard(),
            const SizedBox(height: 20),
            Obx(() => _orderSummaryCard(homeController)),
            const SizedBox(height: 20),
            _saveAndPayButton(homeController),
          ],
        ),
      ),
    );
  }

  Widget _deliveryAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Delivery Address",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            Material(
              color: _storeGreen,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _pickAddress,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: List.generate(_addressController.addresses.length, (i) {
              final addr = _addressController.addresses[i];
              final detail = "[${addr.label}] ${addr.fullAddress}${addr.note.isEmpty ? "" : "\nNote: ${addr.note}"}";
              final isSelected = selectedAddressId == addr.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _addressCard(
                  index: i,
                  addressId: addr.id,
                  title: addr.label,
                  detail: detail,
                  selected: isSelected,
                  onTap: () => setState(() => selectedAddressId = addr.id),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _addressCard({
    required int index,
    required String addressId,
    required String title,
    required String detail,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<int>(
                value: index,
                groupValue: selected ? index : -999999,
                onChanged: (v) => onTap(),
                activeColor: _storeGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final confirm = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text("Delete address"),
                      content: const Text("Are you sure you want to delete this address?"),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
                        TextButton(onPressed: () => Get.back(result: true), child: const Text("Delete")),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  await _addressController.deleteAddress(addressId);
                  if (selectedAddressId == addressId) {
                    setState(() => selectedAddressId = "");
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _promoCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.snackbar("Promo", "Promo support will be added soon"),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _blueLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _blueLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_offer_outlined, color: _blue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apply Promo, Coupon or Voucher",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Get discount with your order.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _instantPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          if (isPaymentLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...paymentMethods.map((method) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _paymentTile(
                    id: method.id,
                    title: method.name,
                    subtitle: method.description,
                    icon: _iconForMethod(method.id),
                  ),
                )),
        ],
      ),
    );
  }

  IconData _iconForMethod(String methodId) {
    switch (methodId) {
      case "cod":
        return Icons.local_shipping_outlined;
      case "wallet":
        return Icons.account_balance_wallet_outlined;
      case "bkash":
        return Icons.phone_android_rounded;
      case "card":
        return Icons.credit_card_rounded;
      default:
        return Icons.payments_outlined;
    }
  }

  Widget _paymentTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = selectedPayment == id;
    return Material(
      color: selected ? _blueLight : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => selectedPayment = id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: selected ? _blue : Colors.grey.shade700, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? _storeGreen : Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderSummaryCard(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 10),
          ...controller.cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${item.name} x${item.quantity}",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "\$${item.lineTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _summaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          _summaryRow("Tax", "\$${tax.toStringAsFixed(2)}"),
          _summaryRow("Delivery Charge", "\$${deliveryCharge.toStringAsFixed(2)}"),
          _summaryRow("Discount", "\$${discount.toStringAsFixed(2)}"),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveAndPayButton(HomeController controller) {
    return Material(
      color: _storeGreen,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: _storeGreen.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onPayNow(controller),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: const Text(
            "Pay now",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPayNow(HomeController controller) async {
    if (selectedAddressId.isEmpty) {
      Get.snackbar("Address", "Please select a delivery address first");
      return;
    }
    PaymentMethodModel? selectedMethod;
    for (final method in paymentMethods) {
      if (method.id == selectedPayment) {
        selectedMethod = method;
        break;
      }
    }
    if (selectedMethod == null) {
      Get.snackbar("Payment", "Please select a payment method");
      return;
    }
    final method = selectedMethod;

    if (method.requiresAction) {
      final success = await Get.to<bool>(
        () => PaymentProcessPage(
          method: method,
          amount: total,
          addressId: selectedAddressId,
        ),
      );
      if (success != true) return;
    } else {
      final response = await _apiClient.post(
        ApiEndpoints.payments.process,
        withAuth: true,
        body: {
          "method": method.id,
          "amount": total,
          "addressId": selectedAddressId,
          "payload": {},
        },
      );
      if (response.statusCode != 200) {
        Get.snackbar("Payment", _extractMessage(response.body));
        return;
      }
    }

    AddressModel? selectedAddress;
    for (final addr in _addressController.addresses) {
      if (addr.id == selectedAddressId) {
        selectedAddress = addr;
        break;
      }
    }
    if (selectedAddress == null) {
      Get.snackbar("Address", "Selected address not found");
      return;
    }

    final createOrderResponse = await _apiClient.post(
      ApiEndpoints.orders.create,
      withAuth: true,
      body: {
        "addressId": selectedAddressId,
        "paymentMethod": method.id,
        "subtotal": subtotal,
        "tax": tax,
        "deliveryCharge": deliveryCharge,
        "discount": discount,
        "total": total,
      },
    );
    if (createOrderResponse.statusCode != 201) {
      Get.snackbar("Order", _extractMessage(createOrderResponse.body, fallback: "Failed to create order"));
      return;
    }
    final orderDecoded = jsonDecode(createOrderResponse.body) as Map<String, dynamic>;
    final orderData = Map<String, dynamic>.from(orderDecoded["data"] as Map? ?? {});
    final orderId = (orderData["_id"] ?? "").toString();
    final addressText = (orderData["addressText"] ?? "").toString();

    Get.snackbar(
      "Success",
      "Order placed with ${method.name}",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    await controller.fetchCart();
    await Get.off(
      () => OrderTrackingPage(
        orderId: orderId,
        paymentMethod: method.name,
        total: total,
        addressText: addressText,
      ),
    );
  }
}

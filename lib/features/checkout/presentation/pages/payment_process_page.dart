import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/payment_method_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class PaymentProcessPage extends StatefulWidget {
  final PaymentMethodModel method;
  final double amount;
  final String addressId;

  const PaymentProcessPage({
    super.key,
    required this.method,
    required this.amount,
    required this.addressId,
  });

  @override
  State<PaymentProcessPage> createState() => _PaymentProcessPageState();
}

class _PaymentProcessPageState extends State<PaymentProcessPage> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.method.fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _extractMessage(String body, {String fallback = "Payment failed"}) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return (decoded["message"] ?? fallback).toString();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _submit() async {
    final payload = <String, dynamic>{};
    for (final field in widget.method.fields) {
      final value = _controllers[field.key]?.text.trim() ?? "";
      if (field.required && value.isEmpty) {
        Get.snackbar("Payment", "${field.label} is required");
        return;
      }
      payload[field.key] = value;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.payments.process,
        withAuth: true,
        body: {
          "method": widget.method.id,
          "amount": widget.amount,
          "addressId": widget.addressId,
          "payload": payload,
        },
      );
      if (response.statusCode != 200) {
        Get.snackbar("Payment", _extractMessage(response.body));
        return;
      }
      Get.back(result: true);
    } catch (_) {
      Get.snackbar("Payment", "Payment request failed");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  LinearGradient _headerGradient() {
    switch (widget.method.id) {
      case "bkash":
        return const LinearGradient(colors: [Color(0xFFE2136E), Color(0xFFC70F5F)]);
      case "card":
        return const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF2563EB)]);
      case "wallet":
        return const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]);
      default:
        return const LinearGradient(colors: [Color(0xFF334155), Color(0xFF0F172A)]);
    }
  }

  IconData _methodIcon() {
    switch (widget.method.id) {
      case "bkash":
        return Icons.phone_android_rounded;
      case "card":
        return Icons.credit_card_rounded;
      case "wallet":
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
            decoration: BoxDecoration(gradient: _headerGradient()),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${widget.method.name} Payment",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                Icon(_methodIcon(), color: Colors.white, size: 24),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.lock_outline_rounded, color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Amount: \$${widget.amount.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.method.description,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...widget.method.fields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              controller: _controllers[field.key],
                              obscureText: field.type == "password",
                              keyboardType: field.key.toLowerCase().contains("phone") ||
                                      field.key.toLowerCase().contains("card") ||
                                      field.key.toLowerCase().contains("pin")
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                labelText: field.label,
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(
                    _isSubmitting ? "Processing..." : "Confirm Payment",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

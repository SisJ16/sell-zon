import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  final String paymentMethod;
  final double total;
  final String addressText;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    required this.total,
    required this.addressText,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      "Placed",
      "Confirmed",
      "Packed",
      "Shipped",
      "Out for delivery",
      "Delivered",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Order Tracking"),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Order Confirmed", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  "Order #$orderId",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text("Payment: $paymentMethod", style: const TextStyle(color: Colors.white)),
                Text("Total: \$${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(addressText),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delivery Timeline", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...List.generate(steps.length, (index) {
                  final isDone = index == 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isDone ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                            color: isDone ? Colors.black : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

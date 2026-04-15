import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const Center(child: Text("Cart is empty"));
        }

        return Column(
          children: [
            /// 🔥 CUSTOM HEADER
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      /// 🔙 Back
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "My Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${controller.cartQuantityCount} items",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            /// 🛒 LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];

                    return Dismissible(
                        key: Key(item.productId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => controller.removeFromCart(item.productId),


                    /// 🔴 Swipe background
                    background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                    ),

                    child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                    /// 🔥 PREMIUM GRADIENT
                    gradient: LinearGradient(
                    colors: [
                    Colors.white,
                    Colors.blue.withOpacity(0.05),
                    ],
                    ),

                    boxShadow: [
                    BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.08),
                    )
                    ],
                    ),

                    child: Row(
                    children: [

                    /// IMAGE
                    ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(item.image, height: 70, width: 70),
                    ),

                    const SizedBox(width: 12),

                    /// INFO
                    Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                    Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),

                    Text("\$${item.price}",
                    style: const TextStyle(color: Color(0xFF2563EB))),

                    const SizedBox(height: 10),

                    /// 🔥 QUANTITY CONTROL
                    Row(
                    children: [

                    GestureDetector(
                    onTap: () => controller.decreaseQty(item),
                    child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, size: 16),
                    ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                    "${item.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(width: 10),

                    /// 🔥 ANIMATED BUTTON
                    GestureDetector(
                    onTap: () => controller.increaseQty(item),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add,
                    size: 16, color: Colors.white),
                    ),
                    ),
                    ],
                    ),
                    ],
                    ),
                    ),

                    /// DELETE ICON
                    GestureDetector(
                    onTap: () => controller.removeFromCart(item.productId),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                    )
                    ],
                    ),
                    ),


                    );
                  }

              ),
            ),

            /// 💰 TOTAL SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.05),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "\$${controller.totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// 🚀 BUTTON
                  GestureDetector(
                    onTap: () => Get.to(() => const CheckoutPage()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Checkout Now 🚀",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}

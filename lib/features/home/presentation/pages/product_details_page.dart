import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/product_model.dart';
import '../../controllers/home_controller.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          /// 🖼 IMAGE SECTION
          Stack(
            children: [
              Container(
                height: 320,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        )
                      ],
                    ),
                    child: Hero(
                      tag: product.name,
                      child: Image.network(
                        product.image,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ),

              /// 🔙 Back Button
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

              /// ❤️ Wishlist
              Positioned(
                top: 40,
                right: 16,
                child: Obx(() {
                  final isFav = controller.isInWishlist(product.id);

                  return GestureDetector(
                    onTap: () async {
                      await controller.toggleWishlist(product);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          /// 📦 DETAILS
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(" ${product.rating}"),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// Price
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Description
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description.isEmpty
                        ? "High quality premium gadget with best performance and durability. Perfect for daily use."
                        : product.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),

                  /// 🛒 ADD TO CART BUTTON
                  GestureDetector(
                    onTap: () async {
                      final added = await controller.addToCart(product);
                      if (!added) return;
                      Get.snackbar(
                        "Added",
                        "${product.name} added to cart",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Add to Cart",
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
            ),
          )
        ],
      ),
    );
  }
}

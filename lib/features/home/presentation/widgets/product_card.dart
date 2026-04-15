import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/product_model.dart';
import '../../controllers/home_controller.dart';
import '../pages/product_details_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsPage(product: product));
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          /// ❤️ Wishlist Icon
          Align(
            alignment: Alignment.topRight,
            child: Obx(() {
              final isFav = controller.isInWishlist(product.id);

              return GestureDetector(
                onTap: () => controller.toggleWishlist(product),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
              );
            }),
          ),

          const SizedBox(height: 5),

          /// 🖼 Image
          Expanded(
            child: Center(
              child: Hero(
                tag: product.name,
                child: Image.network(product.image, fit: BoxFit.contain),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 📦 Name
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 4),

          /// ⭐ Rating
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              Text(" ${product.rating}"),
            ],
          ),

          const SizedBox(height: 6),

          /// 💰 Price
          Text(
            "\$${product.price}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 8),
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
                margin: const EdgeInsets.all(10),
                borderRadius: 10,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
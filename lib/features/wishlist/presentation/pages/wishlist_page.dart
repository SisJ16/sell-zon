import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../home/controllers/home_controller.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.wishlist.isEmpty) {
        return const Center(child: Text("No items in wishlist 💔"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.wishlist.length,
        itemBuilder: (context, index) {
          final item = controller.wishlist[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: Row(
              children: [
                Image.network(item.image, height: 60, width: 60),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("\$${item.price}", style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleWishlist(item),
                  child: const Icon(Icons.favorite, color: Colors.red),
                )
              ],
            ),
          );
        },
      );
    });
  }
}
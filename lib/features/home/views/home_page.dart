import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/widgets/badge_icon.dart';
import '../controllers/home_controller.dart';
import '../presentation/widgets/category_card.dart';
import '../presentation/widgets/product_card.dart';
import '../../wishlist/presentation/pages/wishlist_page.dart';
import '../../cart/presentation/pages/cart_page.dart';
import '../../profile/presentation/pages/profile_page.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final pages = [
    const HomeContent(),
    const WishlistPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;

      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: selectedIndex == 2
            ? null
            : AppBar(
                title: Text(
                  selectedIndex == 0
                      ? "SellZon"
                      : selectedIndex == 1
                          ? "Wishlist"
                          : "Profile",
                ),
                centerTitle: true,
              ),
        body: pages[selectedIndex],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              )
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => controller.selectedIndex.value = index,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: BadgeIcon(
                  icon: Icons.favorite,
                  count: controller.wishlist.length,
                  isActive: selectedIndex == 1,
                ),
                label: "Wishlist",
              ),
              BottomNavigationBarItem(
                icon: BadgeIcon(
                  icon: Icons.shopping_cart,
                  count: controller.cartQuantityCount,
                  isActive: selectedIndex == 2,
                ),
                label: "Cart",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      );
    });
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search gadgets...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isBannersLoading.value) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.banners.isEmpty) {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Big Sale 🎧",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.banners.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final banner = controller.banners[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          banner.image,
                          width: MediaQuery.of(context).size.width - 32,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: MediaQuery.of(context).size.width - 32,
                            height: 150,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 32,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (banner.subtitle.isNotEmpty)
                                Text(
                                  banner.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final selectedCategory = controller.selectedCategory.value;
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: DummyData.categories.length,
                itemBuilder: (context, index) {
                  final category = DummyData.categories[index];
                  return CategoryCard(
                    category: category,
                    isSelected: selectedCategory == category.name,
                    onTap: () => controller.toggleCategoryFilter(category.name),
                  );
                },
              ),
            );
          }),
          Obx(() {
            if (controller.selectedCategory.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text(
                    "Filtered: ${controller.selectedCategory.value}",
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => controller.toggleCategoryFilter(controller.selectedCategory.value),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            "Popular Products",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final selectedCategory = controller.selectedCategory.value;
            final products = selectedCategory.isEmpty
                ? controller.products.toList()
                : controller.products
                    .where(
                      (product) =>
                          product.category.trim().toLowerCase() ==
                          selectedCategory.trim().toLowerCase(),
                    )
                    .toList();

            if (controller.isProductsLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text("No products found in this category"),
              );
            }

            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

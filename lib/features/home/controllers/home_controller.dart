import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/product_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var wishlist = <Product>[].obs;
  var cartItems = <CartItem>[].obs;
  var products = <Product>[].obs;
  var isProductsLoading = false.obs;
  var banners = <HomeBanner>[].obs;
  var isBannersLoading = false.obs;
  var isWishlistLoading = false.obs;
  var isCartLoading = false.obs;
  var selectedCategory = "".obs;

  final ApiClient _apiClient = Get.find<ApiClient>();

  String _extractMessage(String body, {String fallback = "Request failed"}) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return (decoded["message"] ?? fallback).toString();
    } catch (_) {
      return fallback;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchProducts();
    fetchWishlist();
    fetchCart();
  }

  Future<void> fetchBanners() async {
    isBannersLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoints.banners.list);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = decoded["data"] as List<dynamic>? ?? [];
        banners.assignAll(
          items
              .map((item) => HomeBanner.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList(),
        );
      } else {
        banners.clear();
      }
    } catch (_) {
      banners.clear();
    } finally {
      isBannersLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    isProductsLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoints.products.list);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = decoded["data"] as List<dynamic>? ?? [];
        products.assignAll(
          items
              .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList(),
        );
      } else {
        products.clear();
      }
    } catch (_) {
      products.clear();
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> fetchWishlist() async {
    isWishlistLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoints.wishlist.list, withAuth: true);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = decoded["data"] as List<dynamic>? ?? [];
        wishlist.assignAll(
          items
              .map((item) => Map<String, dynamic>.from(item as Map))
              .map((item) => Product.fromJson(Map<String, dynamic>.from(item["productId"] as Map? ?? {})))
              .where((item) => item.id.isNotEmpty)
              .toList(),
        );
      } else {
        wishlist.clear();
      }
    } catch (_) {
      wishlist.clear();
    } finally {
      isWishlistLoading.value = false;
    }
  }

  Future<void> fetchCart() async {
    isCartLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoints.cart.get, withAuth: true);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = Map<String, dynamic>.from(decoded["data"] as Map? ?? {});
        final List<dynamic> items = data["items"] as List<dynamic>? ?? [];
        cartItems.assignAll(
          items
              .map((item) => CartItem.fromApi(Map<String, dynamic>.from(item as Map)))
              .where((item) => item.productId.isNotEmpty)
              .toList(),
        );
      } else {
        cartItems.clear();
      }
    } catch (_) {
      cartItems.clear();
    } finally {
      isCartLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    final category = selectedCategory.value.trim().toLowerCase();
    if (category.isEmpty) {
      return products;
    }

    return products
        .where((product) => product.category.trim().toLowerCase() == category)
        .toList();
  }

  void toggleCategoryFilter(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = "";
      return;
    }

    selectedCategory.value = category;
  }

  Future<bool> toggleWishlist(Product product) async {
    if (product.id.isEmpty || product.id.startsWith("dummy-")) {
      Get.snackbar("Error", "Real product data not loaded yet");
      return false;
    }
    final exists = isInWishlist(product.id);
    try {
      if (exists) {
        final response = await _apiClient.delete(
          ApiEndpoints.wishlist.remove(product.id),
          withAuth: true,
        );
        if (response.statusCode != 200) {
          Get.snackbar("Error", _extractMessage(response.body));
          return false;
        }
      } else {
        final response = await _apiClient.post(
          ApiEndpoints.wishlist.add,
          withAuth: true,
          body: {"productId": product.id},
        );
        if (response.statusCode != 200) {
          Get.snackbar("Error", _extractMessage(response.body));
          return false;
        }
      }
      await fetchWishlist();
      return true;
    } catch (_) {
      Get.snackbar("Error", "Wishlist request failed");
      return false;
    }
  }

  bool isInWishlist(String productId) {
    return wishlist.any((item) => item.id == productId);
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (product.id.isEmpty || product.id.startsWith("dummy-")) {
      Get.snackbar("Error", "Real product data not loaded yet");
      return false;
    }
    try {
      final response = await _apiClient.post(
        ApiEndpoints.cart.addItem,
        withAuth: true,
        body: {"productId": product.id, "quantity": quantity},
      );
      if (response.statusCode != 200) {
        Get.snackbar("Error", _extractMessage(response.body));
        return false;
      }
      await fetchCart();
      return true;
    } catch (_) {
      Get.snackbar("Error", "Cart request failed");
      return false;
    }
  }

  Future<void> increaseQty(CartItem item) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.cart.updateItem(item.productId),
        withAuth: true,
        body: {"quantity": item.quantity + 1},
      );
      await fetchCart();
    } catch (_) {}
  }

  Future<void> decreaseQty(CartItem item) async {
    final nextQuantity = item.quantity - 1;
    try {
      await _apiClient.patch(
        ApiEndpoints.cart.updateItem(item.productId),
        withAuth: true,
        body: {"quantity": nextQuantity},
      );
      await fetchCart();
    } catch (_) {}
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _apiClient.delete(ApiEndpoints.cart.removeItem(productId), withAuth: true);
      await fetchCart();
    } catch (_) {}
  }

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.lineTotal);
  }

  int get cartQuantityCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
}

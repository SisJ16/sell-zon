class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  double get lineTotal => price * quantity;

  factory CartItem.fromApi(Map<String, dynamic> json) {
    final product = Map<String, dynamic>.from(json["product"] as Map? ?? {});
    return CartItem(
      productId: (product["_id"] ?? product["id"] ?? "").toString(),
      name: (product["name"] ?? "").toString(),
      image: (product["image"] ?? "").toString(),
      price: (product["price"] as num?)?.toDouble() ?? 0,
      quantity: (json["quantity"] as num?)?.toInt() ?? 1,
    );
  }
}

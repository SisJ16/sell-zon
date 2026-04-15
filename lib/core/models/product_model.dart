class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final String category;
  final String description;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      image: (json["image"] ?? "").toString(),
      price: (json["price"] as num?)?.toDouble() ?? 0,
      rating: 4.5,
      category: (json["category"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      isActive: (json["isActive"] as bool?) ?? true,
    );
  }
}

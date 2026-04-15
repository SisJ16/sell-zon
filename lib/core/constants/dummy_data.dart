import '../models/product_model.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';

class DummyData {

  static List<Category> categories = [
    Category(
      name: "Headphone",
      icon: Icons.headphones,
      colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
    ),
    Category(
      name: "AirPods",
      icon: Icons.bluetooth_audio,
      colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
    ),
    Category(
      name: "Smart Watch",
      icon: Icons.watch,
      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
  ];
  static List<Product> products = [
    Product(
      id: "dummy-1",
      name: "AirPods Pro",
      image: "https://m.media-amazon.com/images/I/61SUj2aKoEL._AC_SL1500_.jpg",
      price: 249,
      rating: 4.8,
      category: "AirPods",
      description: "Premium wireless earbuds with ANC.",
      isActive: true,
    ),
    Product(
      id: "dummy-2",
      name: "Smart Watch",
      image: "https://m.media-amazon.com/images/I/71Swqqe7XAL._AC_SL1500_.jpg",
      price: 199,
      rating: 4.6,
      category: "Smart Watch",
      description: "Smart watch for fitness and notifications.",
      isActive: true,
    ),
    Product(
      id: "dummy-3",
      name: "Headphone",
      image: "https://m.media-amazon.com/images/I/61CGHv6kmWL._AC_SL1500_.jpg",
      price: 149,
      rating: 4.5,
      category: "Headphone",
      description: "Over-ear headphone with clear sound.",
      isActive: true,
    ),
  ];
}

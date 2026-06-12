import 'package:flutter/foundation.dart';

class ProductItem {
  final String name;
  final double price;
  final double? originalPrice;
  final String icon;
  final String rating;
  final String description;
  final String seller;
  final List<String> tags;

  ProductItem({
    required this.name,
    required this.price,
    this.originalPrice,
    required this.icon,
    required this.rating,
    this.description = "",
    this.seller = "Doe Tech Store",
    this.tags = const [],
  });
}

class ProductRepository {
  static final ValueNotifier<List<ProductItem>> publishedProducts = ValueNotifier<List<ProductItem>>([
    ProductItem(
      name: "Smart Watch Series X",
      price: 200000,
      originalPrice: 220000,
      icon: "⌚",
      rating: "4.9",
      description: "High quality smart watch with premium design, health monitoring sensors, AMOLED customizable watch faces, and 10 days battery life. Built with stainless steel casing.",
      seller: "Doe Tech Store",
      tags: ["smartwatch", "wearables", "tech"],
    ),
    ProductItem(
      name: "Organic Honey 500ml",
      price: 15000,
      icon: "🍯",
      rating: "4.8",
      description: "100% pure organic raw honey harvested from natural forests.",
      seller: "GreenStore",
      tags: ["honey", "organic", "food"],
    ),
    ProductItem(
      name: "Fresh Tomato Box",
      price: 10000,
      icon: "🍅",
      rating: "4.6",
      description: "Freshly picked organic tomatoes directly from Morogoro farms.",
      seller: "GreenStore",
      tags: ["vegetables", "organic", "fresh"],
    ),
    ProductItem(
      name: "Seedlings Kit",
      price: 25000,
      icon: "🌱",
      rating: "4.7",
      description: "Premium seedling starter kit containing coco peat, trays, and various organic seeds.",
      seller: "Agri Hub",
      tags: ["agriculture", "seeds", "kit"],
    ),
  ]);

  static void addProduct(ProductItem item) {
    publishedProducts.value = [...publishedProducts.value, item];
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/styles.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  // Stories list data
  final List<Map<String, String>> _stories = [
    {"name": "Your Story", "avatar": "👨‍💼"},
    {"name": "Tech Gear", "avatar": "⌚"},
    {"name": "Fashion", "avatar": "👕"},
    {"name": "Food", "avatar": "🍕"},
    {"name": "Home", "avatar": "🏠"},
    {"name": "More", "avatar": "➕"},
  ];

  // Feed items data
  final List<Map<String, dynamic>> _posts = [
    {
      "shopName": "GreenStore",
      "location": "Dar es Salaam",
      "time": "2h",
      "title": "Smart Watch Series X",
      "price": 120000.0,
      "likes": 128,
      "comments": 24,
      "icon": "⌚",
      "gradient": const LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
    {
      "shopName": "Agri Hub",
      "location": "Morogoro",
      "time": "4h",
      "title": "Fresh Vegetables Basket",
      "price": 5000.0,
      "likes": 96,
      "comments": 12,
      "icon": "🍅🥬🥕",
      "gradient": const LinearGradient(
        colors: [Color(0xFF1E5F3B), Color(0xFF133B26)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
    {
      "shopName": "Fashion Store",
      "location": "Arusha",
      "time": "1d",
      "title": "Casual Premium Shoes",
      "price": 95000.0,
      "likes": 210,
      "comments": 45,
      "icon": "👟",
      "gradient": const LinearGradient(
        colors: [Color(0xFF5C3D2E), Color(0xFF2D1E17)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Marketplace", style: AppStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: AppStyles.inputDecoration(
                "Search products, shops, items...",
                prefixIcon: const Icon(Icons.search, color: AppStyles.textMuted),
              ),
            ),
            const SizedBox(height: 20),

            // Stories / Categories horizontal list
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _stories.length,
                itemBuilder: (context, index) {
                  final story = _stories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppStyles.accentGold, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF1E1E22),
                            child: Text(
                              story["avatar"]!,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story["name"]!,
                          style: GoogleFonts.outfit(color: AppStyles.textMain, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Feed Posts List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Shop Header
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppStyles.accentGold.withOpacity(0.1),
                              child: Text(
                                post["shopName"].substring(0, 1),
                                style: const TextStyle(color: AppStyles.accentGold, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post["shopName"],
                                    style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${post["location"]} • ${post["time"]} ago",
                                    style: AppStyles.bodyMuted.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // Post Image placeholder with rich gradient
                      Container(
                        height: 220,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: post["gradient"],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          post["icon"],
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),

                      // Title & Price Info
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post["title"],
                              style: AppStyles.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _currencyFormat.format(post["price"]),
                              style: GoogleFonts.outfit(
                                color: AppStyles.accentGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Bar (Like, Comment, Share)
                      Divider(color: Colors.white.withOpacity(0.06), height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                              onPressed: () {},
                            ),
                            Text("${post["likes"]}", style: AppStyles.bodyMuted),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                              onPressed: () {},
                            ),
                            Text("${post["comments"]}", style: AppStyles.bodyMuted),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

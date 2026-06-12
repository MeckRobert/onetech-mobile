import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/styles.dart';

// Import all sub-screens
import 'product_details_screen.dart';
import 'shop_profile_screen.dart';
import 'live_stream_screen.dart';
import 'leaderboards_screen.dart';
import 'achievements_screen.dart';
import 'privacy_visibility_screen.dart';
import 'ai_advisor_screen.dart';
import '../services/product_repository.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  int _selectedCategoryIndex = 0; // 0 = For You, 1 = Following, 2 = Products, 3 = Reels, 4 = Live
  int _selectedFollowingPillIndex = 0; // For "Following" tab: 0 = All, 1 = Posts, 2 = Reels, 3 = Products

  final List<String> _categories = ["For You", "Following", "Products", "Reels", "Live"];
  final List<String> _followingPills = ["All", "Posts", "Reels", "Products"];

  // Stories list data
  final List<Map<String, String>> _stories = [
    {"name": "Your Story", "avatar": "👨‍💼"},
    {"name": "Agri Hub", "avatar": "🌾"},
    {"name": "Tech World", "avatar": "⌚"},
    {"name": "GreenStore", "avatar": "🥦"},
    {"name": "Fashion", "avatar": "👕"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Marketplace header with Camera, Search/Cart, Messages
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  Text("Marketplace", style: AppStyles.titleLarge.copyWith(fontSize: 24)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                    onPressed: () {},
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: AppStyles.inputDecoration(
                  "Search products, businesses, posts...",
                  prefixIcon: const Icon(Icons.search, color: AppStyles.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stories / Categories horizontal list
            SizedBox(
              height: 94,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _stories.length,
                itemBuilder: (context, index) {
                  final story = _stories[index];
                  final bool isVerified = story["name"] != "Your Story";
                  return GestureDetector(
                    onTap: () {
                      if (story["name"] == "GreenStore") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Viewing ${story["name"]}\'s story!')),
                        );
                      }
                    },
                    child: Padding(
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
                              radius: 26,
                              backgroundColor: const Color(0xFF1E1E22),
                              child: Text(
                                story["avatar"]!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                story["name"]!,
                                style: GoogleFonts.outfit(color: AppStyles.textMain, fontSize: 11),
                              ),
                              if (isVerified) ...[
                                const SizedBox(width: 2),
                                const Icon(Icons.verified, color: Colors.blue, size: 10),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Category Tabs (Pills)
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppStyles.accentGold : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppStyles.accentGold : Colors.white.withValues(alpha: 0.02),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Content Area based on selected Tab
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildCategoryContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildForYouTab();
      case 1:
        return _buildFollowingTab();
      case 2:
        return _buildProductsTab();
      case 3:
        return _buildReelsTab();
      case 4:
        return _buildLiveTab();
      default:
        return _buildForYouTab();
    }
  }

  // ==========================================
  // FOR YOU TAB (Mockup Feed Column 3)
  // ==========================================
  Widget _buildForYouTab() {
    return ListView(
      key: const ValueKey('for_you_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        // Feed Post 1: Agri Hub Maize Sale
        Container(
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Shop details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppStyles.cardBg,
                      child: Text("🌾"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Agri Hub",
                                style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],
                          ),
                          Text(
                            "Morogoro • 2h",
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

              // Post Caption Text
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
                child: Text(
                  "🌽 Sold 1,000kg of maize this month!\n📊 Revenue increased by 20%",
                  style: AppStyles.bodyMain.copyWith(fontSize: 13, height: 1.4),
                ),
              ),

              // Image representation (Corn with play button overlay)
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2A540), Color(0xFF5C3D2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 12),

              // Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 6),
                    Text("120", style: AppStyles.bodyMuted),
                    const SizedBox(width: 20),
                    const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text("25", style: AppStyles.bodyMuted),
                    const Spacer(),
                    const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Interactive Smart Watch Product Card
        Text("Featured Item", style: AppStyles.titleMedium),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: ProductRepository.publishedProducts.value[0])),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: AppStyles.cardDecoration,
            child: Row(
              children: [
                // Product preview watch representation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  alignment: Alignment.center,
                  child: const Text("⌚", style: TextStyle(fontSize: 36)),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart Watch Series X",
                        style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(ProductRepository.publishedProducts.value[0].price),
                        style: GoogleFonts.outfit(
                          color: AppStyles.accentGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppStyles.accentGold, size: 12),
                          const SizedBox(width: 4),
                          Text("4.9", style: GoogleFonts.outfit(color: Colors.white, fontSize: 11)),
                          const SizedBox(width: 8),
                          Text("350 sold", style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Buttons
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: ProductRepository.publishedProducts.value[0])),
                        );
                      },
                      style: AppStyles.goldButton.copyWith(
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                      ),
                      child: Text("Buy Now", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat room opened with seller!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppStyles.accentGold),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: const Size(60, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Chat", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Features Guide Section (Mockup Bottom Guide)
        _buildFeaturesGuide(),
      ],
    );
  }

  // ==========================================
  // FOLLOWING TAB (Mockup Column 1 bottom row)
  // ==========================================
  Widget _buildFollowingTab() {
    return Column(
      key: const ValueKey('following_tab'),
      children: [
        // Sub Navigation Pills: All, Posts, Reels, Products
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _followingPills.length,
            itemBuilder: (context, index) {
              final pill = _followingPills[index];
              final isSelected = _selectedFollowingPillIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFollowingPillIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppStyles.accentGold : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    pill,
                    style: GoogleFonts.outfit(
                      color: isSelected ? AppStyles.accentGold : AppStyles.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Following Post 1: Tech World
              _buildFollowingPost(
                shopName: "Tech World",
                avatar: "⌚",
                caption: "🚀 New gadgets in stock! Limited time offer. Check smartwatches and audio wear.",
                gradient: const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF000000)]),
                postIcon: "🎧🕶️⌚",
                likes: 58,
                comments: 14,
              ),
              const SizedBox(height: 16),

              // Following Post 2: Fashion Store
              _buildFollowingPost(
                shopName: "Fashion Store",
                avatar: "👕",
                caption: "New collection dropping this Friday! Stay tuned 🔥",
                gradient: const LinearGradient(colors: [Color(0xFF5C3D2E), Color(0xFF2D1E17)]),
                postIcon: "👗🧥👟",
                likes: 210,
                comments: 45,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowingPost({
    required String shopName,
    required String avatar,
    required String caption,
    required Gradient gradient,
    required String postIcon,
    required int likes,
    required int comments,
  }) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppStyles.cardBg,
                  child: Text(avatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(shopName, style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                      ),
                      Text("1h ago", style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
            child: Text(
              caption,
              style: AppStyles.bodyMain.copyWith(fontSize: 13, height: 1.4),
            ),
          ),
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: gradient,
            ),
            alignment: Alignment.center,
            child: Text(postIcon, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Text("$likes", style: AppStyles.bodyMuted),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text("$comments", style: AppStyles.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PRODUCTS TAB (Mockup Catalog)
  // ==========================================
  Widget _buildProductsTab() {
    return ValueListenableBuilder<List<ProductItem>>(
      valueListenable: ProductRepository.publishedProducts,
      builder: (context, products, child) {
        return GridView.builder(
          key: const ValueKey('products_tab'),
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final item = products[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(product: item),
                  ),
                );
              },
              child: Container(
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        alignment: Alignment.center,
                        child: Text(item.icon, style: const TextStyle(fontSize: 48)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(item.price),
                            style: GoogleFonts.outfit(color: AppStyles.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppStyles.accentGold, size: 12),
                              const SizedBox(width: 4),
                              Text(item.rating, style: GoogleFonts.outfit(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // REELS TAB (Mockup Column 4 top row)
  // ==========================================
  Widget _buildReelsTab() {
    return ListView(
      key: const ValueKey('reels_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        // Reels row header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reels", style: AppStyles.titleMedium),
            Text("View All", style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),

        // Grid/Row of reels
        Row(
          children: [
            Expanded(
              child: _buildReelCard(
                title: "How we pack your orders with care",
                shop: "Agri Hub",
                views: "12k",
                likes: 230,
                color: const Color(0xFF1E5F3B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReelCard(
                title: "New Collection Just Arrived!",
                shop: "Fashion Store",
                views: "240",
                likes: 164,
                color: const Color(0xFF5C3D2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Trending Businesses row (Mockup Column 4 bottom section)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Trending Businesses 🔥", style: AppStyles.titleMedium),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardsScreen()),
                );
              },
              child: Text("View All", style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Trending Shop Card: GreenStore
        Container(
          padding: const EdgeInsets.all(14),
          decoration: AppStyles.cardDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppStyles.cardBg,
                    child: Text("🥦"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "GreenStore",
                              style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.blue, size: 14),
                          ],
                        ),
                        Text(
                          "Verified Business",
                          style: AppStyles.bodyMuted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Following GreenStore!'), backgroundColor: Colors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.accentGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(60, 30),
                    ),
                    child: Text("Follow", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTrendingStat("Business Health", "🛡️ 92/100"),
                  _buildTrendingStat("Followers", "12.5K"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReelCard({
    required String title,
    required String shop,
    required String views,
    required int likes,
    required Color color,
  }) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        gradient: LinearGradient(
          colors: [color, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(Icons.play_circle_outline, color: Colors.white.withValues(alpha: 0.6), size: 48),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "@$shop",
                  style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "$views views",
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "$likes",
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingStat(String label, String val) {
    return Column(
      children: [
        Text(label, style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  // ==========================================
  // LIVE TAB (Interactive Live Stream listing)
  // ==========================================
  Widget _buildLiveTab() {
    return GridView.builder(
      key: const ValueKey('live_tab'),
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final String shop = index == 0 ? "GreenStore" : "Fashion Store";
        final String title = index == 0 ? "Selling Organic Honey 🍯" : "Premium Shoes clearance 👟";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LiveStreamScreen()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: index == 0
                    ? [const Color(0xFF2C1C30), const Color(0xFF140D17)]
                    : [const Color(0xFF1E2A38), const Color(0xFF0F151C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Stack(
              children: [
                // Live overlay elements
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "LIVE",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          index == 0 ? "320" : "150",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center visual camera overlay icon
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.videocam, color: Colors.white54, size: 40),
                ),

                // Details bottom
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop,
                        style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // FEATURES GUIDE FOOTER
  // ==========================================
  Widget _buildFeaturesGuide() {
    final List<Map<String, dynamic>> guides = [
      {
        "title": "Social Feed",
        "icon": Icons.rss_feed,
        "action": () => setState(() => _selectedCategoryIndex = 0),
      },
      {
        "title": "Stories",
        "icon": Icons.history_toggle_off,
        "action": () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tap on any avatar above to view active stories!'))),
      },
      {
        "title": "Reels",
        "icon": Icons.movie_creation_outlined,
        "action": () => setState(() => _selectedCategoryIndex = 3),
      },
      {
        "title": "Live Selling",
        "icon": Icons.live_tv,
        "action": () => setState(() => _selectedCategoryIndex = 4),
      },
      {
        "title": "AI Assistant",
        "icon": Icons.psychology_rounded,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIAdvisorScreen()),
          );
        },
      },
      {
        "title": "Verified Business",
        "icon": Icons.verified,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
          );
        },
      },
      {
        "title": "Leaderboards",
        "icon": Icons.leaderboard,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaderboardsScreen()),
          );
        },
      },
      {
        "title": "Achievements",
        "icon": Icons.emoji_events,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementsScreen()),
          );
        },
      },
      {
        "title": "Settings",
        "icon": Icons.settings,
        "action": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyVisibilityScreen()),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white12, height: 40),
        Text("Why ONETECH Marketplace is Different", style: AppStyles.titleMedium.copyWith(fontSize: 16)),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              return GestureDetector(
                onTap: guide["action"],
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 12, bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(guide["icon"], color: AppStyles.accentGold, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        guide["title"],
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

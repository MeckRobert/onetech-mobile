import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';
import 'product_details_screen.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  final List<String> _tabs = ["Posts", "Products", "Reels", "Stories", "About"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Header Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppStyles.accentGold, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundColor: AppStyles.cardBg,
                            child: Text("🥦", style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "GreenStore",
                                    style: AppStyles.titleLarge.copyWith(fontSize: 22),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, color: Colors.blue, size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Active now",
                                    style: AppStyles.bodyMuted.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Follow & Message buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? Colors.white.withValues(alpha: 0.1) : AppStyles.accentGold,
                              foregroundColor: _isFollowing ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _isFollowing ? "Following" : "Follow",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bio and Location
                    Text(
                      "Fresh produce, vegetables, and fruits at the best price.",
                      style: AppStyles.bodyMain.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppStyles.textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Dar es Salaam, Tanzania",
                          style: AppStyles.bodyMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem("12.5K", "Followers"),
                          _buildDivider(),
                          _buildStatItem("156", "Products"),
                          _buildDivider(),
                          _buildStatItem("4.8 ★", "Rating"),
                          _buildDivider(),
                          _buildStatItem("92/100", "Health Score"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badges row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTextBadge("Verified Business", Colors.blue),
                          const SizedBox(width: 8),
                          _buildTextBadge("Top Performer", AppStyles.accentGold),
                          const SizedBox(width: 8),
                          _buildTextBadge("Fast Growth", Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  indicatorColor: AppStyles.accentGold,
                  labelColor: AppStyles.accentGold,
                  unselectedLabelColor: AppStyles.textMuted,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
                  isScrollable: true,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(),
            _buildProductsTab(),
            _buildReelsTab(),
            _buildStoriesTab(),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.bodyMuted.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.1));
  }

  Widget _buildTextBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPostsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppStyles.cardBg,
                      child: Text("🥦"),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("GreenStore", style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
                        Text("3h ago", style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
                child: Text(
                  "We just received a new organic vegetables! 🥬🍅 Fresh, crunchy and full of vitamins. Visited us today at Kariakoo market or order delivery.",
                  style: AppStyles.bodyMain.copyWith(fontSize: 13, height: 1.4),
                ),
              ),
              // Grid of images
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(colors: [Color(0xFF1E5F3B), Color(0xFF133B26)]),
                        ),
                        alignment: Alignment.center,
                        child: const Text("🥬", style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFF7F0000)]),
                        ),
                        alignment: Alignment.center,
                        child: const Text("🍅", style: TextStyle(fontSize: 48)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 18),
                    const SizedBox(width: 6),
                    Text("96", style: AppStyles.bodyMuted),
                    const SizedBox(width: 20),
                    const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text("18", style: AppStyles.bodyMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    final List<Map<String, dynamic>> products = [
      {"name": "Organic Honey 500ml", "price": 15000, "icon": "🍯"},
      {"name": "Fresh Tomato Box", "price": 10000, "icon": "🍅"},
      {"name": "Seedlings Kit", "price": 25000, "icon": "🌱"},
      {"name": "Smart Watch Series X", "price": 120000, "icon": "⌚"},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductDetailsScreen()),
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
                    child: Text(item["icon"], style: const TextStyle(fontSize: 48)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "TZS ${item["price"]}",
                        style: GoogleFonts.outfit(color: AppStyles.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _buildReelsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            gradient: LinearGradient(
              colors: index == 0
                  ? [const Color(0xFF1E5F3B), const Color(0xFF0F0F10)]
                  : [const Color(0xFFE2A540).withValues(alpha: 0.3), const Color(0xFF0F0F10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Icon(Icons.play_circle_outline, color: Colors.white.withValues(alpha: 0.8), size: 40),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      index == 0 ? "Harvesting Corn..." : "Packaging Honey jars",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          index == 0 ? "1.2k views" : "800 views",
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoriesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          alignment: Alignment.center,
          child: Text(
            index == 0 ? "🌾" : (index == 1 ? "📦" : "🚛"),
            style: const TextStyle(fontSize: 32),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("About GreenStore", style: AppStyles.titleMedium),
              const SizedBox(height: 12),
              Text(
                "GreenStore is a certified supplier of organic produce and farming kits in Dar es Salaam. Established in 2024, we aim to bridge the gap between fresh farms and urban households.",
                style: AppStyles.bodyMain.copyWith(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
              ),
              const Divider(color: Colors.white12, height: 32),
              _buildAboutInfoRow("Business Status", "Verified & Registered"),
              _buildAboutInfoRow("Registration No.", "TZA-7489-2024"),
              _buildAboutInfoRow("Operating Hours", "08:00 AM - 06:00 PM"),
              _buildAboutInfoRow("Contact Email", "support@greenstore.co.tz"),
              _buildAboutInfoRow("Phone", "+255 700 000 000"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.bodyMuted),
          Text(value, style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppStyles.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

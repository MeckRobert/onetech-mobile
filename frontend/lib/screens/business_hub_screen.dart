import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/styles.dart';
import '../services/product_repository.dart';

// Import sub-screens
import 'add_product_screen.dart';
import 'my_products_screen.dart';
import 'product_details_screen.dart';

class BusinessHubScreen extends StatefulWidget {
  const BusinessHubScreen({super.key});

  @override
  State<BusinessHubScreen> createState() => _BusinessHubScreenState();
}

class _BusinessHubScreenState extends State<BusinessHubScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

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
        title: Text(
          "Business Hub",
          style: AppStyles.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Store details card (Screen 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppStyles.accentGold.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Text("🏪", style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Business",
                              style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  "Doe Tech Store",
                                  style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 10),
                                      const SizedBox(width: 2),
                                      Text(
                                        "Verified Business",
                                        style: GoogleFonts.outfit(
                                          color: Colors.green,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 16),
                  
                  // Row of stats (Followers, Products, Orders Today, Rating)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Followers", "2,350"),
                      _buildStatDivider(),
                      _buildStatItem("Products", "48"),
                      _buildStatDivider(),
                      _buildStatItem("Orders Today", "17"),
                      _buildStatDivider(),
                      _buildStatItem("Rating", "★ 4.8"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // + Add Product Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
              style: AppStyles.goldButton.copyWith(
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.black, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "Add Product",
                    style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Title
            Text(
              "Quick Actions",
              style: AppStyles.titleMedium,
            ),
            const SizedBox(height: 12),

            // Quick Actions Grid (Screen 2)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: [
                _buildQuickAction(Icons.inventory_2_outlined, "Products", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                  );
                }),
                _buildQuickAction(Icons.receipt_long_outlined, "Orders", () {}),
                _buildQuickAction(Icons.analytics_outlined, "Analytics", () {}),
                _buildQuickAction(Icons.chat_bubble_outline_rounded, "Messages", () {}),
                _buildQuickAction(Icons.campaign_outlined, "Advertisements", () {}),
                _buildQuickAction(Icons.star_outline_rounded, "Reviews", () {}),
                _buildQuickAction(Icons.local_offer_outlined, "Coupons", () {}),
                _buildQuickAction(Icons.people_outline_rounded, "Customers", () {}),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Products Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Products",
                  style: AppStyles.titleMedium,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                    );
                  },
                  child: Text(
                    "View All",
                    style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Products list (dynamic observation using ValueNotifier)
            ValueListenableBuilder<List<ProductItem>>(
              valueListenable: ProductRepository.publishedProducts,
              builder: (context, products, child) {
                // Reverse to show newly added first, and take top 3
                final recent = products.reversed.take(3).toList();
                
                return Column(
                  children: recent.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: AppStyles.cardDecoration,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            alignment: Alignment.center,
                            child: Text(item.icon, style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat.format(item.price),
                                  style: GoogleFonts.outfit(color: AppStyles.accentGold, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "In Stock",
                              style: GoogleFonts.outfit(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: AppStyles.textMuted),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: item)),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.bodyMuted.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white12,
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecoration,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppStyles.accentGold, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

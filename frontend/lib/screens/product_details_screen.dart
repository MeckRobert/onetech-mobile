import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/styles.dart';
import '../services/product_repository.dart';
import 'shop_profile_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductItem? product;
  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    // Determine product details
    final String name = widget.product?.name ?? "Smart Watch Series X";
    final double price = widget.product?.price ?? 200000;
    final double? originalPrice = widget.product?.originalPrice;
    final String icon = widget.product?.icon ?? "⌚";
    final String rating = widget.product?.rating ?? "4.9";
    final String description = widget.product?.description ?? 
        "High quality smart watch with premium design, health monitoring sensors, AMOLED customizable watch faces, and 10 days battery life. Built with stainless steel casing.";
    final String seller = widget.product?.seller ?? "Doe Tech Store";

    final bool isWatch = icon == "⌚";

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
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product link copied to clipboard!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Hero Image (Visual Excellence)
            Container(
              height: 380,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2C2A24),
                    AppStyles.background,
                  ],
                  radius: 0.8,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular ambient glow
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppStyles.accentGold.withValues(alpha: 0.1),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  
                  // Render based on product type
                  if (isWatch)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppStyles.accentGold, width: 3),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B1B1E), Color(0xFF0F0F10)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "09:41",
                                  style: GoogleFonts.outfit(
                                    color: AppStyles.accentGold,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  "MON 12",
                                  style: GoogleFonts.outfit(
                                    color: AppStyles.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.red, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      "72 BPM",
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Product Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppStyles.titleLarge.copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _currencyFormat.format(price),
                                  style: GoogleFonts.outfit(
                                    color: AppStyles.accentGold,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (originalPrice != null) ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    _currencyFormat.format(originalPrice),
                                    style: GoogleFonts.outfit(
                                      color: AppStyles.textMuted,
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: AppStyles.accentGold,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isBookmarked ? 'Product saved!' : 'Product unsaved.',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppStyles.accentGold, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        " (235 reviews)",
                        style: AppStyles.bodyMuted,
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 12, color: Colors.white24),
                      const SizedBox(width: 12),
                      Text(
                        "350 sold",
                        style: AppStyles.bodyMuted.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 12, color: Colors.white24),
                      const SizedBox(width: 12),
                      const Icon(Icons.visibility_outlined, color: AppStyles.textMuted, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "2.3k views",
                        style: AppStyles.bodyMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Badges list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProductBadge(Icons.verified_user_outlined, "1 Year Warranty"),
                      _buildProductBadge(Icons.local_shipping_outlined, "Fast Delivery"),
                      _buildProductBadge(Icons.assignment_return_outlined, "7 Days Return"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text("Description", style: AppStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppStyles.bodyMuted.copyWith(height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Sold by Shop Card
                  Text("Sold by", style: AppStyles.titleMedium),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppStyles.accentGold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Text("🏪", style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    seller,
                                    style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text("Dar es Salaam, Tanzania", style: AppStyles.bodyMuted),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "View Shop",
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: const Color(0xFF141416),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to Cart!')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppStyles.accentGold, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Add to Cart",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showCheckoutDialog(context, name, price),
                  style: AppStyles.goldButton.copyWith(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  ),
                  child: Text(
                    "Buy Now",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppStyles.accentGold, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, String name, double price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyles.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Confirm Order",
            style: AppStyles.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are buying: $name",
                style: AppStyles.bodyMain,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Price:", style: AppStyles.bodyMuted),
                  Text(_currencyFormat.format(price), style: GoogleFonts.outfit(color: AppStyles.accentGold, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Delivery Fee:", style: AppStyles.bodyMuted),
                  Text("Free", style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    _currencyFormat.format(price),
                    style: GoogleFonts.outfit(
                      color: AppStyles.accentGold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.outfit(color: AppStyles.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order Placed Successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: AppStyles.goldButton,
              child: Text("Confirm & Pay", style: GoogleFonts.outfit(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}

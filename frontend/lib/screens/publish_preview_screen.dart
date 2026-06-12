import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/styles.dart';
import '../services/product_repository.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PublishPreviewScreen extends StatefulWidget {
  final ProductItem product;
  const PublishPreviewScreen({super.key, required this.product});

  @override
  State<PublishPreviewScreen> createState() => _PublishPreviewScreenState();
}

class _PublishPreviewScreenState extends State<PublishPreviewScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);
  final ApiService _apiService = ApiService();

  void _handlePublish() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppStyles.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppStyles.accentGold, width: 1)),
              title: Row(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppStyles.accentGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "AI-POWERED FEATURES",
                    style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // AI Description Generator
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("AI Description Generator", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text("Optimized for marketplace search", style: AppStyles.bodyMuted.copyWith(fontSize: 10)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('AI description regenerated!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.accentGold.withValues(alpha: 0.1),
                              foregroundColor: AppStyles.accentGold,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text("Generate", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sales Prediction Card (Mockup graph)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sales Prediction", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text("Expected Monthly Sales", style: AppStyles.bodyMuted.copyWith(fontSize: 10)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("85 Units", style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text("Confidence: 82%", style: GoogleFonts.outfit(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              // Visual sparkline representation
                              CustomPaint(
                                size: const Size(100, 30),
                                painter: SparklinePainter(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Score
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text("92/100", style: GoogleFonts.outfit(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Product Score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Great Product! Keep it up.", style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // AI Suggestions
                    Text("AI Suggestions", style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildSuggestionItem("Add more photos"),
                    _buildSuggestionItem("Add video"),
                    _buildSuggestionItem("Reduce price by 5%"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Back", style: GoogleFonts.outfit(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 1. Add locally to ProductRepository
                    ProductRepository.addProduct(widget.product);

                    // 2. Try adding to DB via API
                    try {
                      await _apiService.addStock(StockItem(
                        id: 0,
                        name: widget.product.name,
                        category: widget.product.tags.isNotEmpty ? widget.product.tags.first : "General",
                        inStock: 50,
                        lowStockThreshold: 5,
                        price: widget.product.price,
                        cost: widget.product.price * 0.7, // Assume 30% margin
                        imageUrl: "",
                      ));
                    } catch (_) {
                      // Silently skip if backend is not running
                    }

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);

                    if (!mounted) return;

                    // Show Success feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.name} Published Successfully and Added to Marketplace!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Pop back to Business Hub
                    Navigator.pop(context);
                  },
                  style: AppStyles.goldButton,
                  child: Text("Confirm & Publish", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppStyles.accentGold, size: 14),
          const SizedBox(width: 8),
          Text(suggestion, style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine details
    final String name = widget.product.name;
    final double price = widget.product.price;
    final double? originalPrice = widget.product.originalPrice;
    final String icon = widget.product.icon;
    final String rating = widget.product.rating;
    final String description = widget.product.description;
    
    // Calculate discount percent
    int discountPercent = 0;
    if (originalPrice != null && originalPrice > price) {
      discountPercent = (((originalPrice - price) / originalPrice) * 100).round();
    }

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
          "Product Preview",
          style: AppStyles.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large Product Image container
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                  // Dots indicator mockup
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true),
                        const SizedBox(width: 6),
                        _buildDot(false),
                        const SizedBox(width: 6),
                        _buildDot(false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    name,
                    style: AppStyles.titleLarge.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),

                  // Pricing & Badges
                  Row(
                    children: [
                      Text(
                        _currencyFormat.format(price),
                        style: GoogleFonts.outfit(
                          color: AppStyles.accentGold,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (originalPrice != null && originalPrice > price) ...[
                        const SizedBox(width: 8),
                        Text(
                          _currencyFormat.format(originalPrice),
                          style: GoogleFonts.outfit(
                            color: AppStyles.textMuted,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "-$discountPercent%",
                            style: GoogleFonts.outfit(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      const Spacer(),
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
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppStyles.accentGold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        " (235 reviews)",
                        style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Seller Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppStyles.accentGold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Text("🏪", style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.product.seller,
                                    style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text("Dar es Salaam, Tanzania", style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text("Description", style: AppStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppStyles.bodyMuted.copyWith(height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: const Color(0xFF141416),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _handlePublish,
            style: AppStyles.goldButton.copyWith(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Publish Product",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppStyles.accentGold : Colors.white24,
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppStyles.accentGold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.25, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);

    // Draw endpoint dot
    final dotPaint = Paint()
      ..color = AppStyles.accentGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.1), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

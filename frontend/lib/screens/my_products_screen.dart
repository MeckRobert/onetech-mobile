import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/styles.dart';
import '../services/product_repository.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to retrieve stock status and count
  Map<String, dynamic> _getStockDetails(ProductItem item) {
    if (item.name.contains("Laptop")) {
      return {"status": "Low Stock", "count": 1, "color": AppStyles.redExpense};
    } else if (item.name.contains("Tomato")) {
      return {"status": "Low Stock", "count": 2, "color": AppStyles.redExpense};
    } else {
      return {"status": "In Stock", "count": 50, "color": Colors.green};
    }
  }

  // Helper to get dummy statistics for high fidelity
  Map<String, String> _getStats(ProductItem item) {
    if (item.name.contains("Headphones")) {
      return {"views": "1,250", "orders": "35", "sales": "2.9M"};
    } else if (item.name.contains("Watch")) {
      return {"views": "980", "orders": "18", "sales": "3.6M"};
    } else if (item.name.contains("Laptop")) {
      return {"views": "620", "orders": "7", "sales": "12.6M"};
    } else if (item.name.contains("Honey")) {
      return {"views": "410", "orders": "12", "sales": "180k"};
    } else if (item.name.contains("Tomato")) {
      return {"views": "150", "orders": "8", "sales": "80k"};
    } else {
      return {"views": "300", "orders": "14", "sales": "350k"};
    }
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
        title: Text(
          "My Products",
          style: AppStyles.titleMedium,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppStyles.accentGold,
          labelColor: AppStyles.accentGold,
          unselectedLabelColor: AppStyles.textMuted,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "In Stock"),
            Tab(text: "Low Stock"),
            Tab(text: "Out of Stock"),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<ProductItem>>(
        valueListenable: ProductRepository.publishedProducts,
        builder: (context, products, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(products), // All
              _buildProductList(products.where((item) => _getStockDetails(item)["status"] == "In Stock").toList()), // In Stock
              _buildProductList(products.where((item) => _getStockDetails(item)["status"] == "Low Stock").toList()), // Low Stock
              _buildProductList([]), // Out of Stock (Empty mockup list)
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
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
                  "Add New Product",
                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppStyles.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              "No products found in this category",
              style: AppStyles.bodyMuted,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final stock = _getStockDetails(item);
        final stats = _getStats(item);
        final Color statusColor = stock["color"];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: AppStyles.cardDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                    ),
                    alignment: Alignment.center,
                    child: Text(item.icon, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _currencyFormat.format(item.price),
                              style: GoogleFonts.outfit(color: AppStyles.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${stock["status"]} (${stock["count"]})",
                                style: GoogleFonts.outfit(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppStyles.textMuted),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 10),
              
              // Performance stats row matching mockup
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatRowItem("Views", stats["views"]!),
                  _buildStatRowItem("Orders", stats["orders"]!),
                  _buildStatRowItem("Sales", "TZS ${stats["sales"]!}"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRowItem(String label, String value) {
    return Row(
      children: [
        Text(
          "$label ",
          style: AppStyles.bodyMuted.copyWith(fontSize: 11),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

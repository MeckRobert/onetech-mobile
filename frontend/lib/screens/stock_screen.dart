import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  bool _isLoading = true;
  List<StockItem> _items = [];
  List<StockItem> _filteredItems = [];
  String _searchQuery = '';
  String _activeFilter = 'All'; // All, In Stock, Low Stock, Out of Stock

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _apiService.fetchStock();
      setState(() {
        _items = items;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load inventory: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applyFilters() {
    List<StockItem> temp = _items;

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply Tab Filter
    if (_activeFilter == 'In Stock') {
      temp = temp.where((item) => item.inStock > item.lowStockThreshold).toList();
    } else if (_activeFilter == 'Low Stock') {
      temp = temp.where((item) => item.inStock > 0 && item.inStock <= item.lowStockThreshold).toList();
    } else if (_activeFilter == 'Out of Stock') {
      temp = temp.where((item) => item.inStock == 0).toList();
    }

    setState(() {
      _filteredItems = temp;
    });
  }

  void _openAddStockSheet() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final qtyController = TextEditingController();
    final thresholdController = TextEditingController();
    final priceController = TextEditingController();
    final costController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add Stock Item", style: AppStyles.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: AppStyles.inputDecoration("Item Name (e.g. Rice 10kg)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: AppStyles.inputDecoration("Category (e.g. Food, Tech)"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: AppStyles.inputDecoration("Quantity"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: thresholdController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: AppStyles.inputDecoration("Low Stock Alert Limit"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: AppStyles.inputDecoration("Selling Price (TZS)"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: costController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: AppStyles.inputDecoration("Cost Price (TZS)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        categoryController.text.isEmpty ||
                        qtyController.text.isEmpty ||
                        thresholdController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        costController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out all fields.'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    final item = StockItem(
                      id: 0,
                      name: nameController.text,
                      category: categoryController.text,
                      inStock: int.parse(qtyController.text),
                      lowStockThreshold: int.parse(thresholdController.text),
                      price: double.parse(priceController.text),
                      cost: double.parse(costController.text),
                      imageUrl: '',
                    );

                    try {
                      await _apiService.addStock(item);
                      Navigator.pop(context);
                      _loadItems();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Stock item added successfully!'), backgroundColor: AppStyles.greenProfit),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding item: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: AppStyles.goldButton,
                  child: const Text("SAVE ITEM"),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.accentGold,
        foregroundColor: Colors.black,
        onPressed: _openAddStockSheet,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Stock (Inventory)", style: AppStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadItems,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilters();
                });
              },
              decoration: AppStyles.inputDecoration(
                "Search stock...",
                prefixIcon: const Icon(Icons.search, color: AppStyles.textMuted),
              ),
            ),
            const SizedBox(height: 16),

            // Status Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'In Stock', 'Low Stock', 'Out of Stock'].map((filter) {
                  final bool isActive = _activeFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeFilter = filter;
                        _applyFilters();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppStyles.accentGold : const Color(0xFF1E1E22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? AppStyles.accentGold : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.outfit(
                          color: isActive ? Colors.black : AppStyles.textMain,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.accentGold))
                  : _filteredItems.isEmpty
                      ? const Center(child: Text("No items found", style: TextStyle(color: AppStyles.textMuted)))
                      : ListView.builder(
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final bool isLow = item.inStock <= item.lowStockThreshold;
                            final bool isOut = item.inStock == 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: AppStyles.cardDecoration,
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF26262B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isOut
                                          ? Icons.block_rounded
                                          : isLow
                                              ? Icons.warning_amber_rounded
                                              : Icons.inventory_2_rounded,
                                      color: isOut
                                          ? AppStyles.redExpense
                                          : isLow
                                              ? Colors.amber
                                              : AppStyles.accentGold,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(
                                          isOut
                                              ? "Out of Stock"
                                              : isLow
                                                  ? "Low Stock: ${item.inStock} left"
                                                  : "In Stock: ${item.inStock}",
                                          style: AppStyles.bodyMuted.copyWith(
                                            color: isOut
                                                ? AppStyles.redExpense
                                                : isLow
                                                    ? Colors.amber
                                                    : AppStyles.greenProfit,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _currencyFormat.format(item.price),
                                    style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

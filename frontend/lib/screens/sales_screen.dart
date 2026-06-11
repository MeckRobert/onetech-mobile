import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  bool _isLoading = true;
  List<SaleRecord> _sales = [];
  List<StockItem> _availableStock = [];
  AnalyticsData? _analytics;
  String _activeTab = 'Weekly';

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    setState(() => _isLoading = true);
    try {
      final sales = await _apiService.fetchSales();
      final analytics = await _apiService.fetchAnalytics();
      final stock = await _apiService.fetchStock();

      setState(() {
        _sales = sales;
        _analytics = analytics;
        _availableStock = stock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sales: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _openRecordSaleSheet() {
    final customerController = TextEditingController();
    final qtyController = TextEditingController();
    
    StockItem? selectedItem;
    if (_availableStock.isNotEmpty) {
      selectedItem = _availableStock.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                        Text("Record Sale", style: AppStyles.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Product Selection Dropdown
                    if (_availableStock.isEmpty)
                      Text("No items in stock. Please add stock items first.", style: TextStyle(color: AppStyles.redExpense))
                    else ...[
                      Text("Select Product", style: AppStyles.bodyMuted),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<StockItem>(
                            dropdownColor: const Color(0xFF1E1E22),
                            value: selectedItem,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: AppStyles.accentGold),
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                            onChanged: (item) {
                              setSheetState(() {
                                selectedItem = item;
                              });
                            },
                            items: _availableStock.map((item) {
                              return DropdownMenuItem<StockItem>(
                                value: item,
                                child: Text("${item.name} (${_currencyFormat.format(item.price)})"),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: customerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppStyles.inputDecoration("Customer Name"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: AppStyles.inputDecoration("Quantity Sold"),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedItem == null ||
                            customerController.text.isEmpty ||
                            qtyController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        final int qty = int.parse(qtyController.text);
                        if (qty > selectedItem!.inStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Insufficient stock. Only ${selectedItem!.inStock} remaining.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        final sale = SaleRecord(
                          id: 0,
                          itemName: selectedItem!.name,
                          quantity: qty,
                          price: selectedItem!.price,
                          totalAmount: selectedItem!.price * qty,
                          customerName: customerController.text,
                          date: DateTime.now(),
                        );

                        try {
                          await _apiService.recordSale(sale);
                          Navigator.pop(context);
                          _loadSalesData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sale recorded successfully!'), backgroundColor: AppStyles.greenProfit),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error logging sale: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: AppStyles.goldButton,
                      child: const Text("RECORD SALE"),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppStyles.background,
        body: Center(child: CircularProgressIndicator(color: AppStyles.accentGold)),
      );
    }

    // Default calculations if analytics fails
    final double salesAmount = _analytics?.salesAmount ?? 750000;
    final double salesPercentage = _analytics?.salesPercentage ?? 15.3;
    final List<ChartPoint> history = _analytics?.salesHistory ?? [];

    return Scaffold(
      backgroundColor: AppStyles.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.accentGold,
        foregroundColor: Colors.black,
        onPressed: _openRecordSaleSheet,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sales", style: AppStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadSalesData,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((tab) {
                  final bool isActive = _activeTab == tab;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTab = tab;
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
                        tab,
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
            const SizedBox(height: 20),

            // Total Sales Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Sales", style: AppStyles.bodyMuted),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currencyFormat.format(salesAmount),
                        style: AppStyles.amountBig,
                      ),
                      Text(
                        "+$salesPercentage% vs yesterday",
                        style: AppStyles.percentGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sales graph
                  if (history.isNotEmpty)
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  final int index = value.toInt();
                                  if (index >= 0 && index < history.length) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        history[index].label,
                                        style: GoogleFonts.outfit(color: AppStyles.textMuted, fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: history.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.value);
                              }).toList(),
                              isCurved: true,
                              color: AppStyles.accentGold,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Sales Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Sales", style: AppStyles.titleMedium),
                Text("View All", style: AppStyles.bodyMuted.copyWith(color: AppStyles.accentGold)),
              ],
            ),
            const SizedBox(height: 12),

            // Sales list
            Expanded(
              child: _sales.isEmpty
                  ? const Center(child: Text("No sales recorded yet", style: TextStyle(color: AppStyles.textMuted)))
                  : ListView.builder(
                      itemCount: _sales.length,
                      itemBuilder: (context, index) {
                        final record = _sales[index];
                        final String dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(record.date);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: AppStyles.cardDecoration,
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppStyles.greenProfit.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.point_of_sale_rounded, color: AppStyles.greenProfit, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.customerName,
                                      style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${record.itemName} (x${record.quantity}) • $dateStr",
                                      style: AppStyles.bodyMuted,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _currencyFormat.format(record.totalAmount),
                                style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, color: AppStyles.greenProfit),
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

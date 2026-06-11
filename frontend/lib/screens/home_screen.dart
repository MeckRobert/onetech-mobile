import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);
  
  bool _isLoading = true;
  AnalyticsData? _analytics;
  List<StockItem> _lowStockItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final analytics = await _apiService.fetchAnalytics();
      final stock = await _apiService.fetchStock();
      final lowStock = stock.where((item) => item.inStock <= item.lowStockThreshold).toList();

      setState(() {
        _analytics = analytics;
        _lowStockItems = lowStock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppStyles.accentGold));
    }

    if (_analytics == null) {
      return const Center(child: Text("Error fetching analytics", style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: AppStyles.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppStyles.accentGold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, John 👋",
                        style: AppStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome back!",
                        style: AppStyles.bodyMuted,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Total Profit Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Profit",
                      style: AppStyles.bodyMuted,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currencyFormat.format(_analytics!.totalProfit),
                          style: AppStyles.amountBig,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppStyles.greenProfit.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_upward_rounded, color: AppStyles.greenProfit, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "+${_analytics!.profitPercentage}%",
                                style: AppStyles.percentGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "vs last month",
                      style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 24),

                    // Profit Chart
                    SizedBox(
                      height: 180,
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
                                  if (index >= 0 && index < _analytics!.salesHistory.length) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        _analytics!.salesHistory[index].label,
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
                              spots: _analytics!.salesHistory.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.value);
                              }).toList(),
                              isCurved: true,
                              color: AppStyles.accentGold,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppStyles.accentGold.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Metrics Grid (Sales, Expenses, Profit)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricMiniCard(
                      "Sales",
                      _currencyFormat.format(_analytics!.salesAmount),
                      "+${_analytics!.salesPercentage}%",
                      true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricMiniCard(
                      "Expenses",
                      _currencyFormat.format(_analytics!.expensesAmount),
                      "${_analytics!.expensePercentage}%",
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text("Quick Actions", style: AppStyles.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionBtn(Icons.add_box_rounded, "Add Stock"),
                  _buildQuickActionBtn(Icons.point_of_sale_rounded, "Record Sale"),
                  _buildQuickActionBtn(Icons.receipt_long_rounded, "Add Expense"),
                  _buildQuickActionBtn(Icons.storefront_rounded, "Marketplace"),
                ],
              ),
              const SizedBox(height: 24),

              // AI Advisor Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF261D10), Color(0xFF1E1E22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppStyles.accentGold.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology_rounded, color: AppStyles.accentGold, size: 24),
                              const SizedBox(width: 8),
                              Text("AI Advisor", style: AppStyles.titleMedium.copyWith(color: AppStyles.accentGold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Get personalized tips and financial suggestions to grow your business margin.",
                            style: AppStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppStyles.accentGold, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Low Stock Alerts
              if (_lowStockItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Low Stock Alerts", style: AppStyles.titleMedium),
                    Text("View All", style: AppStyles.bodyMuted.copyWith(color: AppStyles.accentGold)),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: _lowStockItems.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: AppStyles.cardDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("In Stock: ${item.inStock} (Threshold: ${item.lowStockThreshold})",
                                  style: AppStyles.bodyMuted.copyWith(color: AppStyles.redExpense)),
                            ],
                          ),
                          Text(
                            _currencyFormat.format(item.price),
                            style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, color: AppStyles.accentGold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricMiniCard(String label, String value, String percent, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.bodyMuted),
          const SizedBox(height: 8),
          Text(value, style: AppStyles.bodyMain.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            percent,
            style: isPositive ? AppStyles.percentGreen : AppStyles.percentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Implement action triggers in respective screens
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please navigate to the $label tab to perform this action.')),
          );
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Icon(icon, color: AppStyles.accentGold, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(color: AppStyles.textMain, fontSize: 11),
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

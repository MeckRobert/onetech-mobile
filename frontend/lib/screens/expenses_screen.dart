import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  bool _isLoading = true;
  List<ExpenseRecord> _expenses = [];
  AnalyticsData? _analytics;
  String _activeTab = 'Monthly';

  // Available expense categories
  final List<String> _categories = ["Transport", "Rent", "Salaries", "Utilities", "Others"];

  // Colors for pie chart
  final List<Color> _pieColors = [
    const Color(0xFF34C759), // Transport -> Green
    const Color(0xFF5856D6), // Rent -> Violet/Indigo
    const Color(0xFFFF9500), // Salaries -> Orange
    const Color(0xFF30B0C7), // Utilities -> Teal/Cyan
    const Color(0xFF8E8E93), // Others -> Grey
  ];

  @override
  void initState() {
    super.initState();
    _loadExpensesData();
  }

  Future<void> _loadExpensesData() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _apiService.fetchExpenses();
      final analytics = await _apiService.fetchAnalytics();

      setState(() {
        _expenses = expenses;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load expenses: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _openAddExpenseSheet() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = _categories.first;

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
                        Text("Add Expense", style: AppStyles.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Category", style: AppStyles.bodyMuted),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1E1E22),
                          value: selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppStyles.accentGold),
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() {
                                selectedCategory = val;
                              });
                            }
                          },
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppStyles.inputDecoration("Description (e.g. Fuel for transit)"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: AppStyles.inputDecoration("Amount (TZS)"),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (descriptionController.text.isEmpty || amountController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        final expense = ExpenseRecord(
                          id: 0,
                          category: selectedCategory,
                          description: descriptionController.text,
                          amount: double.parse(amountController.text),
                          date: DateTime.now(),
                        );

                        try {
                          await _apiService.addExpense(expense);
                          Navigator.pop(context);
                          _loadExpensesData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Expense logged successfully!'), backgroundColor: AppStyles.greenProfit),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding expense: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: AppStyles.goldButton,
                      child: const Text("SAVE EXPENSE"),
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

    final double totalExpenses = _analytics?.expensesAmount ?? 1550000;
    final double expensePercentage = _analytics?.expensePercentage ?? -8.1;
    final List<ChartPoint> history = _analytics?.expenseHistory ?? [];
    final Map<String, double> breakdown = _analytics?.expensesBreakdown ?? {};

    return Scaffold(
      backgroundColor: AppStyles.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.accentGold,
        foregroundColor: Colors.black,
        onPressed: _openAddExpenseSheet,
        child: const Icon(Icons.add, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Expenses", style: AppStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadExpensesData,
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

            // Total Expenses Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Expenses", style: AppStyles.bodyMuted),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currencyFormat.format(totalExpenses),
                        style: AppStyles.amountBig,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppStyles.greenProfit.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_downward_rounded, color: AppStyles.greenProfit, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              "${expensePercentage.abs()}%",
                              style: AppStyles.percentGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("vs last month", style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                  const SizedBox(height: 16),

                  // Line chart
                  if (history.isNotEmpty)
                    SizedBox(
                      height: 130,
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

            // Expenses Breakdown Pie Chart Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Expenses Overview", style: AppStyles.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Pie Chart Widget
                      Expanded(
                        child: SizedBox(
                          height: 150,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: breakdown.entries.map((entry) {
                                final int colorIdx = _categories.indexOf(entry.key) % _pieColors.length;
                                return PieChartSectionData(
                                  color: _pieColors[colorIdx],
                                  value: entry.value,
                                  title: '${((entry.value / totalExpenses) * 100).toStringAsFixed(0)}%',
                                  radius: 30,
                                  titleStyle: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Legend list
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: breakdown.entries.map((entry) {
                            final int colorIdx = _categories.indexOf(entry.key) % _pieColors.length;
                            final double pct = (entry.value / totalExpenses) * 100;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: _pieColors[colorIdx],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: AppStyles.bodyMuted.copyWith(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: AppStyles.bodyMuted.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Expenses List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Expenses", style: AppStyles.titleMedium),
                Text("View All", style: AppStyles.bodyMuted.copyWith(color: AppStyles.accentGold)),
              ],
            ),
            const SizedBox(height: 12),

            // Expense log cards
            _expenses.isEmpty
                ? const Center(child: Text("No expenses recorded yet", style: TextStyle(color: AppStyles.textMuted)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _expenses.length > 5 ? 5 : _expenses.length,
                    itemBuilder: (context, index) {
                      final record = _expenses[index];
                      final String dateStr = DateFormat('MMM dd, yyyy').format(record.date);

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
                                color: AppStyles.redExpense.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: AppStyles.redExpense, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.category,
                                    style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${record.description} • $dateStr",
                                    style: AppStyles.bodyMuted,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currencyFormat.format(record.amount),
                              style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, color: AppStyles.redExpense),
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

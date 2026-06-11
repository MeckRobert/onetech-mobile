import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';
import 'bond_details_screen.dart';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  bool _isLoading = true;
  List<Investment> _opportunities = [];
  List<UserInvestment> _portfolio = [];
  double _totalPortfolioVal = 5250000.0;

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    setState(() => _isLoading = true);
    try {
      final opps = await _apiService.fetchInvestments();
      final portfolio = await _apiService.fetchUserInvestments();

      double sum = 0;
      for (var p in portfolio) {
        sum += p.amountInvested;
      }

      setState(() {
        _opportunities = opps;
        _portfolio = portfolio;
        if (sum > 0) {
          _totalPortfolioVal = sum;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load investments: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppStyles.background,
        body: Center(child: CircularProgressIndicator(color: AppStyles.accentGold)),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Investments", style: AppStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadInvestments,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Portfolio Value Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Portfolio", style: AppStyles.bodyMuted),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currencyFormat.format(_totalPortfolioVal),
                        style: AppStyles.amountBig,
                      ),
                      Text(
                        "+12.4% (All time)",
                        style: AppStyles.percentGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Portfolio graph placeholder
                  SizedBox(
                    height: 100,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 4800000),
                              FlSpot(1, 4900000),
                              FlSpot(2, 5100000),
                              FlSpot(3, 5050000),
                              FlSpot(4, 5250000),
                            ],
                            isCurved: true,
                            color: AppStyles.accentGold,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Explore opportunities headers
            Text("Explore Opportunities", style: AppStyles.titleMedium),
            const SizedBox(height: 12),

            // List of opportunities
            _opportunities.isEmpty
                ? const Center(child: Text("No opportunities found", style: TextStyle(color: AppStyles.textMuted)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _opportunities.length,
                    itemBuilder: (context, index) {
                      final item = _opportunities[index];
                      IconData categoryIcon = Icons.show_chart_rounded;
                      if (item.category == 'Bonds') {
                        categoryIcon = Icons.account_balance_rounded;
                      } else if (item.category == 'Real Estate') {
                        categoryIcon = Icons.home_work_rounded;
                      } else if (item.category == 'Agriculture') {
                        categoryIcon = Icons.agriculture_rounded;
                      } else if (item.category == 'Cryptocurrency') {
                        categoryIcon = Icons.currency_bitcoin_rounded;
                      }

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
                                color: AppStyles.accentGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(categoryIcon, color: AppStyles.accentGold, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ROI: ${item.returnRate}% p.a. • Maturity: ${item.maturityYears} yrs",
                                    style: AppStyles.bodyMuted,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BondDetailsScreen(investment: item),
                                  ),
                                ).then((_) => _loadInvestments());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.accentGold,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                "INVEST",
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
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

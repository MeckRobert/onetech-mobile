import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class BondDetailsScreen extends StatefulWidget {
  final Investment investment;

  const BondDetailsScreen({super.key, required this.investment});

  @override
  State<BondDetailsScreen> createState() => _BondDetailsScreenState();
}

class _BondDetailsScreenState extends State<BondDetailsScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS ', decimalDigits: 0);

  void _openInvestAmountSheet() {
    final amountController = TextEditingController(text: widget.investment.minInvestment.toStringAsFixed(0));

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Confirm Investment", style: AppStyles.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "You are investing in:",
                style: AppStyles.bodyMuted,
              ),
              const SizedBox(height: 4),
              Text(
                widget.investment.title,
                style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppStyles.accentGold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: AppStyles.inputDecoration("Enter Investment Amount (TZS)"),
              ),
              const SizedBox(height: 8),
              Text(
                "Minimum investment requirement: ${_currencyFormat.format(widget.investment.minInvestment)}",
                style: AppStyles.bodyMuted.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isEmpty) return;

                  final double amount = double.parse(amountController.text);
                  if (amount < widget.investment.minInvestment) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Amount cannot be less than ${_currencyFormat.format(widget.investment.minInvestment)}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  try {
                    await _apiService.invest(widget.investment.id, amount);
                    Navigator.pop(context); // Close sheet
                    
                    // Show success
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Investment placed successfully!'),
                        backgroundColor: AppStyles.greenProfit,
                      ),
                    );

                    Navigator.pop(context); // Go back to portfolio
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error making investment: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                style: AppStyles.goldButton,
                child: const Text("CONFIRM INVESTMENT"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141416),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.investment.category,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Large Gold Emblem
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppStyles.accentGold.withOpacity(0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppStyles.accentGold.withOpacity(0.2), width: 2),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: AppStyles.accentGold, size: 72),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.investment.title,
                        style: AppStyles.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Fixed Income Security",
                        style: AppStyles.bodyMuted,
                      ),
                      const SizedBox(height: 32),

                      // Investment Specs Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecMetric(
                              "Expected Return",
                              "${widget.investment.returnRate}% p.a.",
                              Icons.arrow_upward_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSpecMetric(
                              "Min. Investment",
                              _currencyFormat.format(widget.investment.minInvestment),
                              Icons.lock_clock_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecMetric(
                              "Maturity",
                              "${widget.investment.maturityYears} Years",
                              Icons.calendar_month_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSpecMetric(
                              "Risk Level",
                              widget.investment.riskLevel,
                              Icons.gavel_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // About content card
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("About", style: AppStyles.titleMedium),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppStyles.cardDecoration,
                        child: Text(
                          widget.investment.description,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action button
              ElevatedButton(
                onPressed: _openInvestAmountSheet,
                style: AppStyles.goldButton,
                child: const Text("INVEST NOW"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppStyles.accentGold, size: 20),
          const SizedBox(height: 12),
          Text(label, style: AppStyles.bodyMuted),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

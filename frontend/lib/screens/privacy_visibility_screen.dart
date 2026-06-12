import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';

class PrivacyVisibilityScreen extends StatefulWidget {
  const PrivacyVisibilityScreen({super.key});

  @override
  State<PrivacyVisibilityScreen> createState() => _PrivacyVisibilityScreenState();
}

class _PrivacyVisibilityScreenState extends State<PrivacyVisibilityScreen> {
  bool _profilePublic = true;
  bool _showHealth = true;
  bool _showRevenue = true;
  bool _showSales = true;
  bool _showInvestment = true;
  bool _showProducts = true;
  bool _showAchievements = true;

  int _audience = 2; // 0 = Only Me, 1 = Followers, 2 = Everyone

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
          "Privacy & Visibility",
          style: AppStyles.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Business Profile Visibility Header
            Text(
              "Business Profile Visibility",
              style: GoogleFonts.outfit(
                color: AppStyles.accentGold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Profile Toggle Switch Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Make my business profile public",
                              style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Build trust and get more customers by making your profile visible.",
                              style: AppStyles.bodyMuted.copyWith(fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _profilePublic,
                        activeColor: AppStyles.accentGold,
                        onChanged: (value) {
                          setState(() {
                            _profilePublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Performance Visibility Header
            Text(
              "Performance Visibility",
              style: GoogleFonts.outfit(
                color: AppStyles.accentGold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Choose what others can see on your profile",
              style: AppStyles.bodyMuted.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Performance Toggles List Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  _buildToggleRow("Business Health Score", _showHealth, (v) => setState(() => _showHealth = v)),
                  const Divider(color: Colors.white12, height: 20),
                  _buildToggleRow("Revenue Growth", _showRevenue, (v) => setState(() => _showRevenue = v)),
                  const Divider(color: Colors.white12, height: 20),
                  _buildToggleRow("Sales Performance", _showSales, (v) => setState(() => _showSales = v)),
                  const Divider(color: Colors.white12, height: 20),
                  _buildToggleRow("Investment Performance", _showInvestment, (v) => setState(() => _showInvestment = v)),
                  const Divider(color: Colors.white12, height: 20),
                  _buildToggleRow("Products & Services", _showProducts, (v) => setState(() => _showProducts = v)),
                  const Divider(color: Colors.white12, height: 20),
                  _buildToggleRow("Achievements & Badges", _showAchievements, (v) => setState(() => _showAchievements = v)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Audience Header
            Text(
              "Audience",
              style: GoogleFonts.outfit(
                color: AppStyles.accentGold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Audience Selectors Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  _buildAudienceRow(0, "Only Me"),
                  const Divider(color: Colors.white12, height: 1),
                  _buildAudienceRow(1, "Followers"),
                  const Divider(color: Colors.white12, height: 1),
                  _buildAudienceRow(2, "Everyone"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Footnote info
            Text(
              "You can change these settings anytime. Changes are saved automatically.",
              style: AppStyles.bodyMuted.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 30,
          child: Switch(
            value: value,
            activeColor: AppStyles.accentGold,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAudienceRow(int value, String label) {
    return RadioListTile<int>(
      value: value,
      groupValue: _audience,
      activeColor: AppStyles.accentGold,
      title: Text(
        label,
        style: AppStyles.bodyMain,
      ),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _audience = newValue;
          });
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _selectedFilter = 0; // 0 = All, 1 = Earned, 2 = Locked

  final List<Map<String, dynamic>> _achievements = [
    {
      "title": "Top Seller",
      "description": "Make 100 sales.",
      "earned": true,
      "icon": "🏆",
    },
    {
      "title": "100 Sales Club",
      "description": "Complete 100 sales.",
      "earned": true,
      "icon": "🏅",
    },
    {
      "title": "Trusted Merchant",
      "description": "Get 50 positive reviews.",
      "earned": true,
      "icon": "🤝",
    },
    {
      "title": "Fast Growth Business",
      "description": "Grow revenue by 20%.",
      "earned": true,
      "icon": "📈",
    },
    {
      "title": "Investor",
      "description": "Make your first investment.",
      "earned": false,
      "icon": "💼",
    },
    {
      "title": "Live Seller",
      "description": "Go live for the first time.",
      "earned": false,
      "icon": "🎙️",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final List<Map<String, dynamic>> filteredAchievements = _achievements.where((ach) {
      if (_selectedFilter == 1) return ach["earned"] == true;
      if (_selectedFilter == 2) return ach["earned"] == false;
      return true;
    }).toList();

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
          "Achievements",
          style: AppStyles.titleMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "View All",
              style: GoogleFonts.outfit(color: AppStyles.accentGold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Business Level Card (Visual Excellence)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E2616), Color(0xFF1B1B1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppStyles.accentGold.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Gold Business Badge
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppStyles.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppStyles.accentGold.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "🛡️",
                      style: TextStyle(fontSize: 36),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info and Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Business Level",
                          style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                        ),
                        Text(
                          "Gold Business",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Progress Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "820 / 1000 XP",
                              style: GoogleFonts.outfit(
                                color: AppStyles.accentGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "180 XP to Platinum",
                              style: AppStyles.bodyMuted.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.82,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(AppStyles.accentGold),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Filters
            Row(
              children: [
                _buildFilterButton(0, "All"),
                const SizedBox(width: 8),
                _buildFilterButton(1, "Earned"),
                const SizedBox(width: 8),
                _buildFilterButton(2, "Locked"),
              ],
            ),
            const SizedBox(height: 20),

            // Achievements List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAchievements.length,
              itemBuilder: (context, index) {
                final ach = filteredAchievements[index];
                return _buildAchievementItem(
                  title: ach["title"]!,
                  description: ach["description"]!,
                  earned: ach["earned"]!,
                  icon: ach["icon"]!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(int index, String label) {
    final bool isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.accentGold : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppStyles.accentGold : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String description,
    required bool earned,
    required String icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppStyles.cardDecoration.copyWith(
        border: Border.all(
          color: earned ? AppStyles.accentGold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          // Achievement badge icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: earned ? AppStyles.accentGold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 24,
                color: earned ? null : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & desc
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyMain.copyWith(
                    fontWeight: FontWeight.bold,
                    color: earned ? Colors.white : Colors.white60,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppStyles.bodyMuted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // Status label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: earned ? Colors.green.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              earned ? "Earned" : "Locked",
              style: GoogleFonts.outfit(
                color: earned ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  State<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen> {
  String _selectedPeriod = "This Month";

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
          "Top Growing Businesses",
          style: AppStyles.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown Selector
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    dropdownColor: AppStyles.cardBg,
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    items: ["This Week", "This Month", "All Time"]
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3D Podium Layout (Visual Excellence)
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place: Tech World
                  Expanded(
                    child: _buildPodiumItem(
                      rank: 2,
                      name: "Tech World",
                      growth: "+18%",
                      height: 120,
                      avatar: "⌚",
                      podiumColor: const Color(0xFFC0C0C0), // Silver
                      borderColor: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 1st Place: Agri Hub (Center, highest)
                  Expanded(
                    child: _buildPodiumItem(
                      rank: 1,
                      name: "Agri Hub",
                      growth: "+25%",
                      height: 160,
                      avatar: "🌾",
                      podiumColor: AppStyles.accentGold, // Gold
                      borderColor: Colors.green,
                      hasCrown: true,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 3rd Place: GreenStore
                  Expanded(
                    child: _buildPodiumItem(
                      rank: 3,
                      name: "GreenStore",
                      growth: "+15%",
                      height: 100,
                      avatar: "🥦",
                      podiumColor: const Color(0xFFCD7F32), // Bronze
                      borderColor: AppStyles.accentGoldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Ranking List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Business Name",
                    style: AppStyles.bodyMuted.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Growth Rate",
                    style: AppStyles.bodyMuted.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Runners up list
            _buildRankingItem(rank: 4, name: "Fashion Store", icon: "👕", growth: "+12%"),
            _buildRankingItem(rank: 5, name: "BuildZone", icon: "🧱", growth: "+10%"),
            _buildRankingItem(rank: 6, name: "AutoParts TZ", icon: "⚙️", growth: "+9%"),
            _buildRankingItem(rank: 7, name: "Fresh Fish Co.", icon: "🐟", growth: "+8%"),
            
            const SizedBox(height: 24),

            // View Full Leaderboard Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "View Full Leaderboard",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Footnote info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppStyles.textMuted, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Only businesses with public performance stats enabled appear on the leaderboard.",
                    style: AppStyles.bodyMuted.copyWith(fontSize: 11, height: 1.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required String growth,
    required double height,
    required String avatar,
    required Color podiumColor,
    required Color borderColor,
    bool hasCrown = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar stack with crown if 1st
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 26 : 22,
                backgroundColor: AppStyles.cardBg,
                child: Text(avatar, style: TextStyle(fontSize: rank == 1 ? 26 : 20)),
              ),
            ),
            if (hasCrown)
              const Positioned(
                top: -16,
                child: Text(
                  "👑",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: podiumColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$rank",
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Store Name
        Text(
          name,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // Growth rate
        Text(
          growth,
          style: GoogleFonts.outfit(
            color: AppStyles.greenProfit,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Podium cylinder block
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: AppStyles.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "#$rank",
                style: GoogleFonts.outfit(
                  color: podiumColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required String name,
    required String icon,
    required String growth,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 20,
            child: Text(
              "$rank",
              style: GoogleFonts.outfit(
                color: AppStyles.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Icon / Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),

          // Business Name
          Expanded(
            child: Text(
              name,
              style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Growth Rate
          Text(
            growth,
            style: GoogleFonts.outfit(
              color: AppStyles.greenProfit,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

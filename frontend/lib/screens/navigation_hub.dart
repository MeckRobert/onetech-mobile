import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';

// Import all screens
import 'home_screen.dart';
import 'stock_screen.dart';
import 'sales_screen.dart';
import 'expenses_screen.dart';
import 'ai_advisor_screen.dart';
import 'marketplace_screen.dart';
import 'learn_screen.dart';
import 'invest_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key});

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  // 0 = Business Hub, 1 = Growth Hub
  int _hubMode = 0;
  
  // Tab index for each mode
  int _businessIndex = 0;
  int _growthIndex = 0;

  // Business screens
  final List<Widget> _businessScreens = [
    const HomeScreen(),
    const StockScreen(),
    const SalesScreen(),
    const ExpensesScreen(),
    const AIAdvisorScreen(),
  ];

  // Growth screens
  final List<Widget> _growthScreens = [
    const HomeScreen(),
    const MarketplaceScreen(),
    const LearnScreen(),
    const InvestScreen(),
    const MessagesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Current active screen list
    final List<Widget> activeScreens = _hubMode == 0 ? _businessScreens : _growthScreens;
    final int activeIndex = _hubMode == 0 ? _businessIndex : _growthIndex;

    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141416),
        elevation: 0,
        centerTitle: false,
        // Profile picture on the top-left (leads to Profile Screen)
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppStyles.accentGold, width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppStyles.cardBg,
                child: Text(
                  "JD",
                  style: TextStyle(color: AppStyles.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          "ONETECH",
          style: GoogleFonts.outfit(
            color: AppStyles.accentGold,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          // Hub Mode Toggle Switcher in App Bar
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppStyles.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hubMode = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _hubMode == 0 ? AppStyles.accentGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        "Business",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _hubMode == 0 ? Colors.black : AppStyles.textMuted,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hubMode = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _hubMode == 1 ? AppStyles.accentGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        "Growth",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _hubMode == 1 ? Colors.black : AppStyles.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: activeScreens[activeIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF141416),
        selectedItemColor: AppStyles.accentGold,
        unselectedItemColor: AppStyles.textMuted,
        currentIndex: activeIndex,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 10),
        onTap: (index) {
          setState(() {
            if (_hubMode == 0) {
              _businessIndex = index;
            } else {
              _growthIndex = index;
            }
          });
        },
        items: _hubMode == 0
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Stock',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up_rounded),
                  label: 'Sales',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wallet_rounded),
                  label: 'Expenses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology_rounded),
                  label: 'Advisor',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_rounded),
                  label: 'Market',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_rounded),
                  label: 'Learn',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on_rounded),
                  label: 'Invest',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_rounded),
                  label: 'Messages',
                ),
              ],
      ),
    );
  }
}

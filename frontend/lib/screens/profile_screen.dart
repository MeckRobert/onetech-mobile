import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

// Sub-screens imports
import 'business_hub_screen.dart';
import 'my_products_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  User? _user;

  bool _profileVisibility = true;
  bool _businessCenterExpanded = true; // Keep expanded initially for preview

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _apiService.fetchProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Fallback in case backend is offline
      _user = User(
        id: 1,
        name: "John M. Doe",
        email: "john.doe@onetech.com",
        role: "Business Advisor",
        profileImage: "",
        isVerified: true,
      );
    }
  }

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
          "Profile",
          style: AppStyles.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppStyles.accentGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User info header matching mockup
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppStyles.accentGold, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Color(0xFF1E1E22),
                          child: Text(
                            "JD",
                            style: TextStyle(color: AppStyles.accentGold, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _user?.name ?? "John M. Doe",
                                  style: AppStyles.titleLarge.copyWith(fontSize: 20),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppStyles.accentGold.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppStyles.accentGold.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    _user?.role ?? "Business Advisor",
                                    style: GoogleFonts.outfit(
                                      color: AppStyles.accentGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user?.email ?? "john.doe@onetech.com",
                              style: AppStyles.bodyMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Visibility switch card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Profile Visibility",
                                style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Allow others to discover and view my profile",
                                style: AppStyles.bodyMuted.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _profileVisibility,
                          activeColor: AppStyles.accentGold,
                          onChanged: (val) {
                            setState(() {
                              _profileVisibility = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Collapsible Business Center card (Screen 1)
                  Container(
                    decoration: AppStyles.cardDecoration,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.store_outlined, color: AppStyles.accentGold, size: 24),
                          title: Text(
                            "Business Center",
                            style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Manage your business and products",
                            style: AppStyles.bodyMuted.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(
                            _businessCenterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          onTap: () {
                            setState(() {
                              _businessCenterExpanded = !_businessCenterExpanded;
                            });
                          },
                        ),
                        if (_businessCenterExpanded) ...[
                          const Divider(color: Colors.white10, height: 1),
                          
                          // Promote Business sub-tile -> leads to Business Hub
                          _buildBusinessSubTile(
                            icon: Icons.campaign_outlined,
                            title: "Promote Business",
                            subtitle: "Add products and grow your business in the marketplace",
                            highlighted: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BusinessHubScreen()),
                              );
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1),

                          // My Products sub-tile -> leads to My Products Screen
                          _buildBusinessSubTile(
                            icon: Icons.inventory_2_outlined,
                            title: "My Products",
                            subtitle: "View and manage your products",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                              );
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1),

                          // Orders sub-tile
                          _buildBusinessSubTile(
                            icon: Icons.shopping_bag_outlined,
                            title: "Orders",
                            subtitle: "Manage your orders",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Orders manager is a mockup feature.')),
                              );
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1),

                          // Business Analytics sub-tile
                          _buildBusinessSubTile(
                            icon: Icons.bar_chart_outlined,
                            title: "Business Analytics",
                            subtitle: "Track sales and performance",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Analytics manager is a mockup feature.')),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Other tiles: Payment Methods, Security, Help & Support
                  _buildGeneralTile(Icons.payment_outlined, "Payment Methods"),
                  _buildGeneralTile(Icons.security_outlined, "Security"),
                  _buildGeneralTile(Icons.help_outline_rounded, "Help & Support"),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildBusinessSubTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool highlighted = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: highlighted
          ? BoxDecoration(
              border: Border.all(color: AppStyles.accentGold.withValues(alpha: 0.3), width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: AppStyles.accentGold.withValues(alpha: 0.02),
            )
          : null,
      margin: highlighted ? const EdgeInsets.all(8) : EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: highlighted ? AppStyles.accentGold : Colors.white70, size: 22),
        title: Text(
          title,
          style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyles.bodyMuted.copyWith(fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppStyles.textMuted, size: 12),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGeneralTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppStyles.cardDecoration,
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppStyles.textMuted, size: 12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title details are mockup settings.')),
          );
        },
      ),
    );
  }
}

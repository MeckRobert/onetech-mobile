import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  User? _user;

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
      // Fallback in case backend is offline during profile rendering
      _user = User(id: 1, name: "John M. Doe", email: "john@onetech.com", role: "Business Owner", profileImage: "", isVerified: true);
    }
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
          "Profile",
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppStyles.accentGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Avatar & Verified badge
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppStyles.accentGold, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 46,
                            backgroundColor: Color(0xFF1E1E22),
                            child: Text(
                              "JD",
                              style: TextStyle(color: AppStyles.accentGold, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_user?.isVerified ?? true)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppStyles.greenProfit,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.black, size: 16),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name & Role
                  Center(
                    child: Text(
                      _user?.name ?? "John M. Doe",
                      style: AppStyles.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      _user?.role ?? "Business Owner",
                      style: AppStyles.bodyMuted.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile List Options
                  _buildProfileTile(Icons.store_rounded, "Business Profile", "Manage your company details"),
                  _buildProfileTile(Icons.payment_rounded, "Payment Methods", "Bank transfers, cards and mobile money"),
                  _buildProfileTile(Icons.security_rounded, "Security & Privacy", "Passwords, biometric logins"),
                  _buildProfileTile(Icons.help_outline_rounded, "Help & Support", "FAQ, talk to customer representative"),
                  _buildProfileTile(Icons.person_add_alt_1_rounded, "Invite Friends", "Get rewards for referring shops"),
                  _buildProfileTile(Icons.settings_rounded, "Settings", "Themes, languages, alert thresholds"),
                  _buildProfileTile(Icons.info_outline_rounded, "About ONETECH", "Terms of service, version 1.0.0"),

                  const SizedBox(height: 32),

                  // Logout button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logging out is not enabled in demo mode.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E22),
                      foregroundColor: AppStyles.redExpense,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: AppStyles.redExpense.withOpacity(0.2)),
                    ),
                    child: Text(
                      "LOG OUT",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppStyles.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AppStyles.accentGold, size: 24),
        title: Text(
          title,
          style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyles.bodyMuted,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppStyles.textMuted, size: 14),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title details is a mock screen.')),
          );
        },
      ),
    );
  }
}

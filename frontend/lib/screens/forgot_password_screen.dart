import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailOrPhoneController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final message = await _apiService.forgotPassword(
        _emailOrPhoneController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _successMessage = message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Graphic background grid lines matching branding
          Positioned.fill(
            child: CustomPaint(
              painter: ForgotGridPainter(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: _isSuccess ? _buildSuccessState() : _buildRequestState(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestState() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey("request_form"),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Forgot Password header
          Text(
            "Forgot Password? 🔑",
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppStyles.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your email or phone number and we will send you instructions to reset your password.",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppStyles.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          // Error alert banner if any
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Email or Phone field
          Text(
            "Email or Phone",
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppStyles.textMain.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailOrPhoneController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.outfit(color: AppStyles.textMain, fontSize: 15),
            decoration: AppStyles.inputDecoration(
              "Enter your email or phone",
              prefixIcon: const Icon(Icons.email_outlined, color: AppStyles.textMuted, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your email or phone";
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Send Reset Link Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: AppStyles.goldButton.copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Send Reset Link",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(height: 32),

          // Back to Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password? ",
                style: GoogleFonts.outfit(
                  color: AppStyles.textMuted,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.outfit(
                    color: AppStyles.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      key: const ValueKey("success_card"),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: AppStyles.cardDecoration.copyWith(
        border: Border.all(color: AppStyles.accentGold.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkmark Icon
          Center(
            child: Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyles.accentGold.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: AppStyles.accentGold,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Success message
          Text(
            "Instructions Sent! ✉️",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppStyles.textMain,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _successMessage ?? "Password reset instructions have been sent to your device.",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppStyles.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Back to Login Button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: AppStyles.goldButton.copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            child: Text(
              "Back to Login",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppStyles.accentGold.withValues(alpha: 0.025)
      ..strokeWidth = 1.0;

    double spacing = 45.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += spacing) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }

    // Glow in middle
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: 250);
    final circlePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppStyles.accentGold.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 250, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class HeartInfo {
  final double x;
  final double scale;
  final double duration;
  final Color color;
  final IconData icon;

  HeartInfo({
    required this.x,
    required this.scale,
    required this.duration,
    required this.color,
    required this.icon,
  });
}

class _LiveStreamScreenState extends State<LiveStreamScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> _comments = [
    {"user": "Grace M.", "text": "This is amazing! 😍"},
    {"user": "John D.", "text": "How much is delivery?"},
    {"user": "Aisha T.", "text": "I want to order 2"},
    {"user": "Peter K.", "text": "Do you have in Dar?"},
  ];

  final List<HeartInfo> _hearts = [];
  final Random _random = Random();
  final TextEditingController _commentController = TextEditingController();
  final List<AnimationController> _heartControllers = [];

  void _spawnHeart() {
    final double scale = 0.6 + _random.nextDouble() * 0.6;
    final double duration = 1.5 + _random.nextDouble() * 1.5;
    final Color color = [
      Colors.pink,
      Colors.red,
      Colors.orange,
      AppStyles.accentGold,
      Colors.purple,
    ][_random.nextInt(5)];

    final IconData icon = [
      Icons.favorite,
      Icons.favorite_border,
      Icons.thumb_up,
      Icons.star,
    ][_random.nextInt(4)];

    final HeartInfo heart = HeartInfo(
      x: _random.nextDouble() * 100 - 50, // x offset relative to spawn point
      scale: scale,
      duration: duration,
      color: color,
      icon: icon,
    );

    final AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (duration * 1000).toInt()),
    );

    setState(() {
      _hearts.add(heart);
      _heartControllers.add(controller);
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          int index = _hearts.indexOf(heart);
          if (index != -1) {
            _hearts.removeAt(index);
            _heartControllers[index].dispose();
            _heartControllers.removeAt(index);
          }
        });
      }
    });
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add({
        "user": "You",
        "text": text,
      });
      _commentController.clear();
    });
  }

  @override
  void dispose() {
    for (var controller in _heartControllers) {
      controller.dispose();
    }
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Stream video placeholder with stunning dark camera gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C1C30), Color(0xFF140D17), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative animated visualizer/grain simulating real stream video
          Center(
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.white.withValues(alpha: 0.1), Colors.transparent],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Stream Content Overlay (Safe Area)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header row: LIVE badge, viewer count, exit button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "LIVE",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "320",
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Subheader: Store info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppStyles.cardBg,
                        child: Text("🥦"),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "GreenStore",
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],
                          ),
                          Text(
                            "Organic & Fresh Produce",
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.accentGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          minimumSize: const Size(60, 26),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(
                          "Follow",
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Content: Comments, Hearts and Product highlights
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Comments Box
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _comments.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final comment = _comments[_comments.length - 1 - index];
                              final isMe = comment["user"] == "You";
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${comment['user']}: ",
                                          style: GoogleFonts.outfit(
                                            color: isMe ? AppStyles.accentGold : Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: comment["text"]!,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Spawning animation view area
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: List.generate(_hearts.length, (index) {
                              final heart = _hearts[index];
                              final controller = _heartControllers[index];

                              return AnimatedBuilder(
                                animation: controller,
                                builder: (context, child) {
                                  // Animate vertical translation and horizontal offset
                                  final double progress = controller.value;
                                  final double yTranslation = -200 * progress;
                                  // Wave-like horizontal oscillation
                                  final double xOffset = heart.x + 20 * sin(progress * 2 * pi);

                                  return Positioned(
                                    bottom: 10 + yTranslation,
                                    left: (MediaQuery.of(context).size.width * 0.125) + xOffset,
                                    child: Opacity(
                                      opacity: 1 - progress,
                                      child: Transform.scale(
                                        scale: heart.scale,
                                        child: Icon(
                                          heart.icon,
                                          color: heart.color,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Floating selling product
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1E).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppStyles.accentGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("🍯", style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Organic Honey 500ml",
                                style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "TZS 15,000",
                                style: GoogleFonts.outfit(
                                  color: AppStyles.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you! Redirecting to checkout...'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: AppStyles.goldButton.copyWith(
                            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                          ),
                          child: Text(
                            "Buy Now",
                            style: GoogleFonts.outfit(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Chat inputs and Heart spawn button
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          onSubmitted: (_) => _addComment(),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Say something...",
                            hintStyle: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _addComment,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _spawnHeart,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppStyles.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.black, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

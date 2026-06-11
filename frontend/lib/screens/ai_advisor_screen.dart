import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class AIAdvisorScreen extends StatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  State<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class _AIAdvisorScreenState extends State<AIAdvisorScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingCards = true;
  bool _isSending = false;
  List<AdvisorCard> _cards = [];
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadAdvisorCards();
    _messages.add(ChatMessage(
      text: "Hi John! I have analyzed your transactions. Ask me anything about stock optimization, cash flow margins, or investments.",
      isMe: false,
      time: DateTime.now(),
    ));
  }

  Future<void> _loadAdvisorCards() async {
    setState(() => _isLoadingCards = true);
    try {
      final cards = await _apiService.fetchAdvisorCards();
      setState(() {
        _cards = cards;
        _isLoadingCards = false;
      });
    } catch (e) {
      setState(() => _isLoadingCards = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch AI insights: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _sendMessage() async {
    final query = _chatController.text.trim();
    if (query.isEmpty) return;

    _chatController.clear();
    setState(() {
      _messages.add(ChatMessage(text: query, isMe: true, time: DateTime.now()));
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final reply = await _apiService.askAI(query);
      setState(() {
        _messages.add(ChatMessage(text: reply, isMe: false, time: DateTime.now()));
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Failed to connect to advisor service: $e", isMe: false, time: DateTime.now()));
        _isSending = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Bot Banner
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF141416),
            child: Row(
              children: [
                // Glowing golden bot icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyles.accentGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppStyles.accentGold.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: AppStyles.accentGold, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Advisor",
                        style: AppStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Autonomous business diagnostician",
                        style: AppStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable area (Insight cards + Chat messages)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dynamic diagnostic cards
                  if (_isLoadingCards)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: CircularProgressIndicator(color: AppStyles.accentGold)),
                    )
                  else if (_cards.isNotEmpty) ...[
                    Text("Today's Diagnostics", style: AppStyles.titleMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          final card = _cards[index];
                          IconData icon = Icons.info_outline_rounded;
                          Color color = AppStyles.accentGold;

                          if (card.type == 'recommendation') {
                            icon = Icons.insights_rounded;
                            color = Colors.blue;
                          } else if (card.type == 'suggestion') {
                            icon = Icons.savings_rounded;
                            color = AppStyles.greenProfit;
                          }

                          return Container(
                            width: 260,
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: AppStyles.cardDecoration.copyWith(
                              border: Border.all(color: color.withOpacity(0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(icon, color: color, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      card.title,
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    card.description,
                                    style: AppStyles.bodyMain.copyWith(fontSize: 13, height: 1.3),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Chat conversation
                  Text("Ask Advisor", style: AppStyles.titleMedium),
                  const SizedBox(height: 12),
                  ..._messages.map((msg) => _buildChatBubble(msg)),
                  if (_isSending)
                    _buildChatBubble(ChatMessage(text: "Thinking...", isMe: false, time: DateTime.now())),
                ],
              ),
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
            color: const Color(0xFF141416),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(color: Colors.white),
                    decoration: AppStyles.inputDecoration("Ask me anything..."),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppStyles.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final bool isBotLoading = msg.text == "Thinking...";
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: msg.isMe ? AppStyles.accentGold : const Color(0xFF1E1E22),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
            color: msg.isMe ? AppStyles.accentGold : Colors.white.withOpacity(0.04),
          ),
        ),
        child: isBotLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppStyles.accentGold),
              )
            : Text(
                msg.text,
                style: GoogleFonts.outfit(
                  color: msg.isMe ? Colors.black : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}

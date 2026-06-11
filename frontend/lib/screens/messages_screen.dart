import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/styles.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<ChatRoom> _chatRooms = [];
  String _activeTab = 'Chats';

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _apiService.fetchChatRooms();
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chats: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Messages", style: AppStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadChatRooms,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Switcher (Chats, Orders, Notifications)
            Row(
              children: ['Chats', 'Orders', 'Notifications'].map((tab) {
                final bool isActive = _activeTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTab = tab;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? AppStyles.accentGold : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        style: GoogleFonts.outfit(
                          color: isActive ? AppStyles.accentGold : AppStyles.textMuted,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Chat list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.accentGold))
                  : _activeTab != 'Chats'
                      ? Center(child: Text("No new $_activeTab", style: const TextStyle(color: AppStyles.textMuted)))
                      : _chatRooms.isEmpty
                          ? const Center(child: Text("No active chats", style: TextStyle(color: AppStyles.textMuted)))
                          : ListView.builder(
                              itemCount: _chatRooms.length,
                              itemBuilder: (context, index) {
                                final room = _chatRooms[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: AppStyles.cardDecoration,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppStyles.accentGold.withOpacity(0.1),
                                          child: Text(
                                            room.name.substring(0, 1),
                                            style: const TextStyle(color: AppStyles.accentGold, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (room.active)
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              height: 12,
                                              width: 12,
                                              decoration: BoxDecoration(
                                                color: AppStyles.greenProfit,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppStyles.cardBg, width: 1.5),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(room.name, style: AppStyles.bodyMain.copyWith(fontWeight: FontWeight.bold)),
                                        Text(room.time, style: AppStyles.bodyMuted.copyWith(fontSize: 11)),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        room.lastMessage,
                                        style: AppStyles.bodyMuted,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: AppStyles.textMuted, size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ConversationScreen(chatRoom: room),
                                        ),
                                      ).then((_) => _loadChatRooms());
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// Conversation Thread Screen
class ConversationScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ConversationScreen({super.key, required this.chatRoom});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  List<Message> _messages = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    
    // Start simple polling to catch automatic mock replies
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _loadMessages(silent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final messages = await _apiService.fetchMessages(widget.chatRoom.id);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!silent) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load thread: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    
    try {
      await _apiService.sendMessage(widget.chatRoom.id, "You", text);
      _loadMessages(silent: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
      );
    }
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF141416),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.chatRoom.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Message feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppStyles.accentGold))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final bool isMe = msg.sender == "You";
                      final String timeStr = DateFormat('hh:mm a').format(msg.timestamp);

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? AppStyles.accentGold : const Color(0xFF1E1E22),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content,
                                style: GoogleFonts.outfit(color: isMe ? Colors.black : Colors.white, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  timeStr,
                                  style: GoogleFonts.outfit(color: isMe ? Colors.black54 : AppStyles.textMuted, fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Text bar
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
            color: const Color(0xFF141416),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(color: Colors.white),
                    decoration: AppStyles.inputDecoration("Type a message..."),
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
}

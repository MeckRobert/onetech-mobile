import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl {
    if (kIsWeb) {
      return 'https://onetech-mobile.onrender.com';
    }

    try {
      if (Platform.isAndroid) {
        return 'https://onetech-mobile.onrender.com';
      }
    } catch (_) {}

    return 'https://onetech-mobile.onrender.com';
  }

  // Common GET helper
  Future<dynamic> _get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Common POST helper
  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Server error: ${response.statusCode}');
    }
  }

  // Auth
  Future<User> login(String email, String password) async {
    final data = await _post('/api/login', {'email': email, 'password': password});
    return User.fromJson(data['user']);
  }

  Future<User> fetchProfile() async {
    final data = await _get('/api/profile');
    return User.fromJson(data);
  }

  // Stock / Inventory
  Future<List<StockItem>> fetchStock() async {
    final List data = await _get('/api/stock');
    return data.map((e) => StockItem.fromJson(e)).toList();
  }

  Future<StockItem> addStock(StockItem item) async {
    final data = await _post('/api/stock', item.toJson());
    return StockItem.fromJson(data);
  }

  // Sales
  Future<List<SaleRecord>> fetchSales() async {
    final List data = await _get('/api/sales');
    return data.map((e) => SaleRecord.fromJson(e)).toList();
  }

  Future<SaleRecord> recordSale(SaleRecord sale) async {
    final data = await _post('/api/sales', sale.toJson());
    return SaleRecord.fromJson(data);
  }

  // Expenses
  Future<List<ExpenseRecord>> fetchExpenses() async {
    final List data = await _get('/api/expenses');
    return data.map((e) => ExpenseRecord.fromJson(e)).toList();
  }

  Future<ExpenseRecord> addExpense(ExpenseRecord expense) async {
    final data = await _post('/api/expenses', expense.toJson());
    return ExpenseRecord.fromJson(data);
  }

  // Analytics
  Future<AnalyticsData> fetchAnalytics() async {
    final data = await _get('/api/analytics');
    return AnalyticsData.fromJson(data);
  }

  // Chats & Messaging
  Future<List<ChatRoom>> fetchChatRooms() async {
    final List data = await _get('/api/chat-rooms');
    return data.map((e) => ChatRoom.fromJson(e)).toList();
  }

  Future<List<Message>> fetchMessages(String chatId) async {
    final List data = await _get('/api/messages?chat_id=$chatId');
    return data.map((e) => Message.fromJson(e)).toList();
  }

  Future<Message> sendMessage(String chatId, String sender, String content) async {
    final data = await _post('/api/messages?chat_id=$chatId', {
      'chat_id': chatId,
      'sender': sender,
      'content': content,
    });
    return Message.fromJson(data);
  }

  // Education
  Future<List<Lesson>> fetchLessons() async {
    final List data = await _get('/api/lessons');
    return data.map((e) => Lesson.fromJson(e)).toList();
  }

  // Investments
  Future<List<Investment>> fetchInvestments() async {
    final List data = await _get('/api/investments');
    return data.map((e) => Investment.fromJson(e)).toList();
  }

  Future<List<UserInvestment>> fetchUserInvestments() async {
    final List data = await _get('/api/user-investments');
    return data.map((e) => UserInvestment.fromJson(e)).toList();
  }

  Future<void> invest(int investmentId, double amount) async {
    await _post('/api/user-investments', {
      'investment_id': investmentId,
      'amount': amount,
    });
  }

  // AI Advisor
  Future<List<AdvisorCard>> fetchAdvisorCards() async {
    final List data = await _get('/api/advisor-cards');
    return data.map((e) => AdvisorCard.fromJson(e)).toList();
  }

  Future<String> askAI(String message) async {
    final data = await _post('/api/ai-chat', {'message': message});
    return data['reply'] ?? 'Failed to get advisor response.';
  }
}

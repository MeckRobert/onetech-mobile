import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String profileImage;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profileImage,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileImage: json['profile_image'] ?? '',
      isVerified: (json['is_verified'] == true || json['is_verified'] == 1),
    );
  }
}

class StockItem {
  final int id;
  final String name;
  final String category;
  final int inStock;
  final int lowStockThreshold;
  final double price;
  final double cost;
  final String imageUrl;

  StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.inStock,
    required this.lowStockThreshold,
    required this.price,
    required this.cost,
    required this.imageUrl,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      inStock: json['in_stock'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'in_stock': inStock,
      'low_stock_threshold': lowStockThreshold,
      'price': price,
      'cost': cost,
      'image_url': imageUrl,
    };
  }
}

class SaleRecord {
  final int id;
  final String itemName;
  final int quantity;
  final double price;
  final double totalAmount;
  final String customerName;
  final DateTime date;

  SaleRecord({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.customerName,
    required this.date,
  });

  factory SaleRecord.fromJson(Map<String, dynamic> json) {
    return SaleRecord(
      id: json['id'] ?? 0,
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customer_name'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'customer_name': customerName,
    };
  }
}

class ExpenseRecord {
  final int id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  ExpenseRecord({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseRecord(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
    };
  }
}

class ChatRoom {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final bool active;

  ChatRoom({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    required this.active,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastMessage: json['last_message'] ?? '',
      time: json['time'] ?? '',
      imageUrl: json['image_url'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

class Message {
  final int id;
  final String chatId;
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? '',
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      read: json['read'] == true || json['read'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'sender': sender,
      'content': content,
    };
  }
}

class Lesson {
  final int id;
  final String title;
  final String category;
  final String duration;
  final String level;
  final String description;
  final String content;
  final String imageUrl;

  Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.level,
    required this.description,
    required this.content,
    required this.imageUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class Investment {
  final int id;
  final String title;
  final String category;
  final double returnRate;
  final double minInvestment;
  final int maturityYears;
  final String description;
  final String imageUrl;
  final String riskLevel;

  Investment({
    required this.id,
    required this.title,
    required this.category,
    required this.returnRate,
    required this.minInvestment,
    required this.maturityYears,
    required this.description,
    required this.imageUrl,
    required this.riskLevel,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      returnRate: (json['return_rate'] as num?)?.toDouble() ?? 0.0,
      minInvestment: (json['min_investment'] as num?)?.toDouble() ?? 0.0,
      maturityYears: json['maturity_years'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      riskLevel: json['risk_level'] ?? '',
    );
  }
}

class UserInvestment {
  final int id;
  final int userId;
  final int investmentId;
  final String title;
  final double amountInvested;
  final double returnRate;
  final double expectedReturn;
  final DateTime maturityDate;
  final DateTime dateInvested;

  UserInvestment({
    required this.id,
    required this.userId,
    required this.investmentId,
    required this.title,
    required this.amountInvested,
    required this.returnRate,
    required this.expectedReturn,
    required this.maturityDate,
    required this.dateInvested,
  });

  factory UserInvestment.fromJson(Map<String, dynamic> json) {
    return UserInvestment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      investmentId: json['investment_id'] ?? 0,
      title: json['title'] ?? '',
      amountInvested: (json['amount_invested'] as num?)?.toDouble() ?? 0.0,
      returnRate: (json['return_rate'] as num?)?.toDouble() ?? 0.0,
      expectedReturn: (json['expected_return'] as num?)?.toDouble() ?? 0.0,
      maturityDate: json['maturity_date'] != null ? DateTime.parse(json['maturity_date']) : DateTime.now(),
      dateInvested: json['date_invested'] != null ? DateTime.parse(json['date_invested']) : DateTime.now(),
    );
  }
}

class AdvisorCard {
  final String id;
  final String title;
  final String description;
  final String type;

  AdvisorCard({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });

  factory AdvisorCard.fromJson(Map<String, dynamic> json) {
    return AdvisorCard(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class ChartPoint {
  final String label;
  final double value;

  ChartPoint({
    required this.label,
    required this.value,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsData {
  final double totalProfit;
  final double profitPercentage;
  final double salesAmount;
  final double salesPercentage;
  final double expensesAmount;
  final double expensePercentage;
  final List<ChartPoint> salesHistory;
  final List<ChartPoint> expenseHistory;
  final Map<String, double> expensesBreakdown;

  AnalyticsData({
    required this.totalProfit,
    required this.profitPercentage,
    required this.salesAmount,
    required this.salesPercentage,
    required this.expensesAmount,
    required this.expensePercentage,
    required this.salesHistory,
    required this.expenseHistory,
    required this.expensesBreakdown,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    var sHistList = (json['sales_history'] as List?)
            ?.map((e) => ChartPoint.fromJson(e))
            .toList() ??
        [];
    var eHistList = (json['expense_history'] as List?)
            ?.map((e) => ChartPoint.fromJson(e))
            .toList() ??
        [];

    Map<String, double> breakdown = {};
    if (json['expenses_breakdown'] != null) {
      (json['expenses_breakdown'] as Map<String, dynamic>).forEach((key, value) {
        breakdown[key] = (value as num).toDouble();
      });
    }

    return AnalyticsData(
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      profitPercentage: (json['profit_percentage'] as num?)?.toDouble() ?? 0.0,
      salesAmount: (json['sales_amount'] as num?)?.toDouble() ?? 0.0,
      salesPercentage: (json['sales_percentage'] as num?)?.toDouble() ?? 0.0,
      expensesAmount: (json['expenses_amount'] as num?)?.toDouble() ?? 0.0,
      expensePercentage: (json['expense_percentage'] as num?)?.toDouble() ?? 0.0,
      salesHistory: sHistList,
      expenseHistory: eHistList,
      expensesBreakdown: breakdown,
    );
  }
}

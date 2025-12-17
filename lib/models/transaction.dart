class Transaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String? type;
  final String? category; // New field for budget category

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.type,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
    };
  }

  // Method to get a map representation without the ID, for database insertion.
  Map<String, dynamic> toMapWithoutId() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      category: map['category'],
    );
  }
}

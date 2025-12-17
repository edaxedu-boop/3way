class Investment {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final int transactionId; // Link to the expense transaction

  Investment({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'transactionId': transactionId,
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      transactionId: map['transactionId'],
    );
  }
}

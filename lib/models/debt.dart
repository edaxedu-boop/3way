class Debt {
  final int? id;
  final String title;
  final double totalAmount;
  double remainingAmount;
  final DateTime date;

  Debt({
    this.id,
    required this.title,
    required this.totalAmount,
    required this.remainingAmount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'date': date.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      title: map['title'],
      totalAmount: map['totalAmount'],
      remainingAmount: map['remainingAmount'],
      date: DateTime.parse(map['date']),
    );
  }
}

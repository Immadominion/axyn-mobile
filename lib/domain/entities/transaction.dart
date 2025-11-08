/// Transaction entity representing a completed agent interaction
class Transaction {
  const Transaction({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.userId,
    required this.amount,
    required this.signature,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      agentId: json['agentId'] as int,
      agentName: json['agentName'] as String? ?? 'Unknown Agent',
      userId: json['userId'] as int,
      amount: (json['amount'] as num).toDouble(),
      signature: json['signature'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int id;
  final int agentId;
  final String agentName;
  final int userId;
  final double amount; // USD amount
  final String signature; // Solana transaction signature
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'agentName': agentName,
      'userId': userId,
      'amount': amount,
      'signature': signature,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

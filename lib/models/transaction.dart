enum TransactionType {
  deposit,
  withdrawal,
  transferSend,
  transferReceive,
  payment;

  static TransactionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DEPOSIT':
        return TransactionType.deposit;
      case 'WITHDRAWAL':
        return TransactionType.withdrawal;
      case 'TRANSFER_SEND':
        return TransactionType.transferSend;
      case 'TRANSFER_RECEIVE':
        return TransactionType.transferReceive;
      case 'PAYMENT':
        return TransactionType.payment;
      default:
        return TransactionType.deposit;
    }
  }

  bool get isCredit =>
      this == TransactionType.deposit ||
      this == TransactionType.transferReceive;

  String get label {
    switch (this) {
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.transferSend:
        return 'Transfert envoyé';
      case TransactionType.transferReceive:
        return 'Transfert reçu';
      case TransactionType.payment:
        return 'Paiement facture';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionType.deposit:
        return '💰';
      case TransactionType.withdrawal:
        return '🏧';
      case TransactionType.transferSend:
        return '📤';
      case TransactionType.transferReceive:
        return '📥';
      case TransactionType.payment:
        return '🧾';
    }
  }
}

class Transaction {
  final int id;
  final TransactionType type;
  final double amount;
  final double fees;
  final double netAmount;
  final String? description;
  final DateTime? createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.fees,
    required this.netAmount,
    this.description,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final type = TransactionType.fromString(json['type'] ?? '');
    final double amount = (json['amount'] ?? 0).toDouble();
    final double fees = (json['fees'] ?? 0).toDouble();
    
    final double calculatedNetAmount = type.isCredit ? amount : (amount + fees);

    return Transaction(
      id: json['id'] ?? 0,
      type: type,
      amount: amount,
      fees: fees,
      netAmount: calculatedNetAmount,
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name.toUpperCase(),
        'amount': amount,
        'fees': fees,
        'netAmount': netAmount,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
      };
}

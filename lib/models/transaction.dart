/// Types de transactions correspondant à l'enum Java TransactionType
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

  /// True si la transaction est un crédit (argent reçu)
  bool get isCredit =>
      this == TransactionType.deposit ||
      this == TransactionType.transferReceive;

  /// Libellé lisible en français
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

  /// Icône associée
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
    return Transaction(
      id: json['id'] ?? 0,
      type: TransactionType.fromString(json['type'] ?? ''),
      amount: (json['amount'] ?? 0).toDouble(),
      fees: (json['fees'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
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

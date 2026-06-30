import 'transaction.dart';

class Wallet {
  final int id;
  final String phoneNumber;
  final String? email;
  final String code;
  final String currency;
  final double balance;
  final DateTime? createdAt;
  final List<Transaction> transactions;

  Wallet({
    required this.id,
    required this.phoneNumber,
    this.email,
    required this.code,
    this.currency = 'XOF',
    required this.balance,
    this.createdAt,
    this.transactions = const [],
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final txList = (json['transactions'] as List<dynamic>? ?? [])
        .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
        .toList();

    return Wallet(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      code: json['code'] ?? '',
      currency: json['currency'] ?? 'XOF',
      balance: (json['balance'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      transactions: txList,
    );
  }

  /// Copie avec un nouveau solde (après mise à jour)
  Wallet copyWith({double? balance}) {
    return Wallet(
      id: id,
      phoneNumber: phoneNumber,
      email: email,
      code: code,
      currency: currency,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      transactions: transactions,
    );
  }
}

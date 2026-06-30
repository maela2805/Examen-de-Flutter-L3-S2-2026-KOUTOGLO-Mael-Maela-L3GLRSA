import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../models/transaction.dart';

enum HistoryState { initial, loading, loaded, error }

class HistoryProvider extends ChangeNotifier {
  HistoryState _state = HistoryState.initial;
  String? _phone;
  List<Transaction> _transactions = [];
  String? _errorMessage;

  HistoryState get state => _state;
  List<Transaction> get transactions => _transactions;
  String? get errorMessage => _errorMessage;

  void updatePhone(String? phone) {
    if (phone != null && phone != _phone) {
      _phone = phone;
    }
  }

  Future<void> fetchTransactions() async {
    if (_phone == null) return;
    _state = HistoryState.loading;
    notifyListeners();

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.transactions(_phone!)}',
      );
      final response = await http.get(uri).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        _transactions = list
            .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
            .toList();
        _transactions.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        _state = HistoryState.loaded;
      } else {
        _errorMessage = 'Impossible de charger les transactions.';
        _state = HistoryState.error;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau.';
      _state = HistoryState.error;
    }
    notifyListeners();
  }

  void refresh() => fetchTransactions();
}

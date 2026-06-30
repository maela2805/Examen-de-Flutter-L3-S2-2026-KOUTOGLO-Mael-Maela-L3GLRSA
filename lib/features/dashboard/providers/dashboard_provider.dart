import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../models/transaction.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  DashboardState _state = DashboardState.initial;
  String? _phone;
  double? _balance;
  List<Transaction> _recentTransactions = [];
  String? _errorMessage;

  DashboardState get state => _state;
  double? get balance => _balance;
  List<Transaction> get recentTransactions => _recentTransactions;
  String? get errorMessage => _errorMessage;

  void updatePhone(String? phone) {
    if (phone != null && phone != _phone) {
      _phone = phone;
      fetchDashboard();
    }
  }

  Future<void> fetchDashboard() async {
    if (_phone == null) return;
    _state = DashboardState.loading;
    notifyListeners();

    try {
      await Future.wait([_fetchBalance(), _fetchTransactions()]);
      _state = DashboardState.loaded;
    } catch (e) {
      _errorMessage = 'Impossible de charger le tableau de bord.';
      _state = DashboardState.error;
    }
    notifyListeners();
  }

  Future<void> _fetchBalance() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.balance(_phone!)}',
    );
    final response = await http.get(uri).timeout(ApiConstants.timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _balance = (data['balance'] ?? 0).toDouble();
    }
  }

  Future<void> _fetchTransactions() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.transactions(_phone!)}',
    );
    final response = await http.get(uri).timeout(ApiConstants.timeout);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      final all = list
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList();
      // Trier par date décroissante et prendre les 5 dernières
      all.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      _recentTransactions = all.take(5).toList();
    }
  }

  void refresh() => fetchDashboard();
}

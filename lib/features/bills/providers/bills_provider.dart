import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../models/facture.dart';

enum BillsState { initial, loading, loaded, paying, success, error }

class BillsProvider extends ChangeNotifier {
  BillsState _state = BillsState.initial;
  List<Facture> _factures = [];
  Set<String> _selectedRefs = {};
  String? _errorMessage;
  String? _successMessage;

  BillsState get state => _state;
  List<Facture> get factures => _factures;
  Set<String> get selectedRefs => _selectedRefs;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading =>
      _state == BillsState.loading || _state == BillsState.paying;

  double get selectedTotal => _factures
      .where((f) => _selectedRefs.contains(f.reference))
      .fold(0.0, (sum, f) => sum + f.montant);

  Future<void> fetchFactures(String walletCode, String serviceName) async {
    _state = BillsState.loading;
    _factures = [];
    _selectedRefs = {};
    _errorMessage = null;
    notifyListeners();

    // SENELEC n'existe pas dans le backend, on renvoie directement une liste vide
    if (serviceName.toUpperCase() == 'SENELEC') {
      _state = BillsState.loaded;
      notifyListeners();
      return;
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.facturesCurrent(walletCode)}?unite=$serviceName',
      );
      final response = await http.get(uri).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        _factures = list
            .map((f) => Facture.fromJson(f as Map<String, dynamic>))
            .where((f) => !f.isPaid)
            .toList();
        _state = BillsState.loaded;
      } else {
        _errorMessage = 'Peut-être pas de factures pour le moment';
        _state = BillsState.error;
      }
    } catch (e) {
      _errorMessage = 'Peut-être pas de factures pour le moment';
      _state = BillsState.error;
    }
    notifyListeners();
  }

  void toggleSelection(String reference) {
    if (_selectedRefs.contains(reference)) {
      _selectedRefs.remove(reference);
    } else {
      _selectedRefs.add(reference);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedRefs = _factures.map((f) => f.reference).toSet();
    notifyListeners();
  }

  void clearSelection() {
    _selectedRefs.clear();
    notifyListeners();
  }

  Future<bool> paySelected({
    required String phoneNumber,
    required String serviceName,
  }) async {
    if (_selectedRefs.isEmpty) return false;

    _state = BillsState.paying;
    _errorMessage = null;
    notifyListeners();

    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+221$phoneNumber';

    try {
      final uri =
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.payFactures}');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phoneNumber': formattedPhone,
              'serviceName': serviceName,
              'factureReferences': _selectedRefs.toList(),
            }),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        _successMessage =
            '${_selectedRefs.length} facture(s) payée(s) avec succès !';
        _state = BillsState.success;
        _selectedRefs.clear();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Échec du paiement (${response.statusCode})';
        _state = BillsState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau lors du paiement.';
      _state = BillsState.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _state = BillsState.initial;
    _factures = [];
    _selectedRefs = {};
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

enum TransferState { initial, loading, success, error }

class TransferProvider extends ChangeNotifier {
  TransferState _state = TransferState.initial;
  String? _errorMessage;
  String? _successMessage;

  TransferState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == TransferState.loading;

  Future<bool> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) async {
    _state = TransferState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final formattedSender = senderPhone.startsWith('+') ? senderPhone : '+221$senderPhone';
    final formattedReceiver = receiverPhone.startsWith('+') ? receiverPhone : '+221$receiverPhone';

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transfer}');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'senderPhone': formattedSender,
              'receiverPhone': formattedReceiver,
              'amount': amount,
            }),
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        _successMessage = 'Transfert effectué avec succès !';
        _state = TransferState.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            'Échec du transfert (${response.statusCode}): ${response.body}';
        _state = TransferState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau. Vérifiez votre connexion.';
      _state = TransferState.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _state = TransferState.initial;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

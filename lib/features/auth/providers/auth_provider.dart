import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../models/wallet.dart';

enum AuthState { initial, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthState _state = AuthState.initial;
  String? _phone;
  Wallet? _wallet;
  String? _errorMessage;

  // ─── Getters ─────────────────────────────────────────────────
  AuthState get state => _state;
  String? get phone => _phone;
  Wallet? get wallet => _wallet;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ─── Initialisation au démarrage ─────────────────────────────
  Future<void> init() async {
    final savedPhone = await _storage.read(key: 'phone');
    if (savedPhone != null && savedPhone.isNotEmpty) {
      await login(savedPhone);
    }
  }

  // ─── Connexion avec le numéro de téléphone ───────────────────
  Future<bool> login(String phoneNumber) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+221$phoneNumber';

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.walletByPhone(formattedPhone)}',
      );
      final response = await http.get(uri).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _wallet = Wallet.fromJson(data);
        _phone = formattedPhone;
        _state = AuthState.authenticated;

        // Sauvegarder le numéro de téléphone de façon sécurisée
        await _storage.write(key: 'phone', value: formattedPhone);
        notifyListeners();
        return true;
      } else if (response.statusCode == 404) {
        _errorMessage = 'Aucun wallet trouvé pour ce numéro.';
        _state = AuthState.error;
        notifyListeners();
        return false;
      } else {
        _errorMessage = 'Erreur serveur (${response.statusCode})';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage =
          'Impossible de joindre le serveur. Vérifiez votre connexion.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ─── Déconnexion ─────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.delete(key: 'phone');
    _phone = null;
    _wallet = null;
    _state = AuthState.initial;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) _state = AuthState.initial;
    notifyListeners();
  }
}

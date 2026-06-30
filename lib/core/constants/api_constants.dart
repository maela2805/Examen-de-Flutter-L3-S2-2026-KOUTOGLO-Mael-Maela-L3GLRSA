// Constantes API — BadWallet Consumer App
// Sur émulateur Android : localhost = 10.0.2.2
// Sur vrai téléphone (même WiFi) : remplacer par l'IP locale du PC, ex: 192.168.1.x

class ApiConstants {
  // URL de base du backend
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ─── Wallets ───────────────────────────────────────────────
  static const String wallets = '/api/wallets';

  static String walletByPhone(String phone) =>
      '/api/wallets/$phone';

  static String balance(String phone) =>
      '/api/wallets/$phone/balance';

  static String transactions(String phone) =>
      '/api/wallets/$phone/transactions';

  static const String transfer = '/api/wallets/transfer';
  static const String pay = '/api/wallets/pay';
  static const String payFactures = '/api/wallets/pay-factures';

  // ─── Factures externes ─────────────────────────────────────
  static String facturesCurrent(String walletCode) =>
      '/api/external/factures/$walletCode/current';

  static String facturesPeriode(String walletCode) =>
      '/api/external/factures/$walletCode/periode';

  // ─── Timeout ───────────────────────────────────────────────
  static const Duration timeout = Duration(seconds: 15);
}

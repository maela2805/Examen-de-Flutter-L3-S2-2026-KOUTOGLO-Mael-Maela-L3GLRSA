
class ApiConstants {
  static const String baseUrl = 'http://192.168.1.32:8080';

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

  static String facturesCurrent(String walletCode) =>
      '/api/external/factures/$walletCode/current';

  static String facturesPeriode(String walletCode) =>
      '/api/external/factures/$walletCode/periode';

  static const Duration timeout = Duration(seconds: 15);
}

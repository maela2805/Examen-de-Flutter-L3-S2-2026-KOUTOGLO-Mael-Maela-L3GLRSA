class Facture {
  final String reference;
  final String serviceName;
  final double montant;
  final String? periode;
  final String? statut;
  final DateTime? dateEmission;

  Facture({
    required this.reference,
    required this.serviceName,
    required this.montant,
    this.periode,
    this.statut,
    this.dateEmission,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      reference: json['reference']?.toString() ?? json['id']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ??
          json['service']?.toString() ??
          'Inconnu',
      montant: (json['montant'] ?? json['amount'] ?? 0).toDouble(),
      periode: json['periode']?.toString() ?? json['period']?.toString(),
      statut: json['statut']?.toString() ?? json['status']?.toString(),
      dateEmission: json['dateEmission'] != null
          ? DateTime.tryParse(json['dateEmission'])
          : null,
    );
  }

  bool get isPaid =>
      statut?.toUpperCase() == 'PAID' || statut?.toUpperCase() == 'PAYEE';
}

class BillProvider {
  final String name;
  final String displayName;
  final String emoji;
  final String description;

  const BillProvider({
    required this.name,
    required this.displayName,
    required this.emoji,
    required this.description,
  });

  static const List<BillProvider> providers = [
    BillProvider(
      name: 'SENELEC',
      displayName: 'Senelec',
      emoji: '⚡',
      description: 'Électricité',
    ),
    BillProvider(
      name: 'WOYAFAL',
      displayName: 'Woyafal',
      emoji: '🔥',
      description: 'Gaz',
    ),
    BillProvider(
      name: 'ISM',
      displayName: 'ISM',
      emoji: '🎓',
      description: 'Scolarité',
    ),
  ];
}

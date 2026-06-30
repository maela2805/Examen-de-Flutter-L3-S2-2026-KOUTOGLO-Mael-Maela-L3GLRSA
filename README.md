# 📱 BadWallet Consumer App — Flutter

> **Examen Flutter L3 S2 2026**  
> **Étudiant** : KOUTOGLO Mael Maela — L3 GLRSA  
> **Classe** : L3GLRSA  

---

## 🏗️ Architecture

L'application suit une architecture **Feature-First** avec le pattern **Provider** pour la gestion d'état.

```
lib/
├── core/
│   ├── constants/api_constants.dart     # Endpoints API
│   ├── theme/app_theme.dart             # Thème sombre premium
│   └── utils/currency_formatter.dart    # Formatage XOF & dates
├── models/
│   ├── transaction.dart
│   ├── wallet.dart
│   └── facture.dart
├── features/
│   ├── auth/           # Splash + Login
│   ├── dashboard/      # Home + Solde
│   ├── transfers/      # Transfert + Confirmation
│   ├── bills/          # Factures + Paiement en lot
│   └── history/        # Historique des transactions
└── main.dart
```

## 🌿 Branches Git

| Branche | Fonctionnalité |
|---------|----------------|
| `feature/project-setup` | Setup Flutter, thème, modèles, providers |
| `feature/splash-login` | Splash screen + écran de connexion |
| `feature/dashboard` | Home screen + carte solde + actions |
| `feature/transfers` | Pavé numérique + confirmation transfert |
| `feature/bills` | Liste fournisseurs + paiement en lot |
| `feature/history` | Historique groupé par date |
| `feature/apk-build` | Icône app + build release APK |

## 🚀 Lancer l'application

### Prérequis
- Flutter 3.x
- Backend BadWallet API en cours sur `localhost:8080`
- Émulateur Android (ou vrai appareil)

### Installation
```bash
flutter pub get
flutter run
```

> **Note** : Sur l'émulateur Android, le backend est accessible via `10.0.2.2:8080`.  
> Sur un vrai téléphone (même réseau WiFi), modifier `baseUrl` dans `api_constants.dart` avec l'IP locale du PC.

## 📦 Générer l'APK

```bash
flutter build apk --release
```

L'APK sera généré dans :
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🎨 Design

- **Thème** : Sombre premium (fond #0F0F1A)
- **Couleurs** : Dégradé violet (#6C63FF) → bleu (#3B82F6)
- **Typo** : Poppins (Google Fonts)
- **Transactions** : 🟢 Vert = crédit | 🔴 Rouge = débit

## 🔌 API Backend

| Endpoint | Usage |
|----------|-------|
| `GET /api/wallets/{phone}/balance` | Solde |
| `GET /api/wallets/{phone}/transactions` | Historique |
| `POST /api/wallets/transfer` | Transfert |
| `POST /api/wallets/pay-factures` | Paiement factures |
| `GET /api/external/factures/{code}/current` | Factures du mois |

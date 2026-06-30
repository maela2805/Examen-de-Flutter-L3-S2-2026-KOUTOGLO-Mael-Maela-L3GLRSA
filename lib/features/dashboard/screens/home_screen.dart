import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../transfers/screens/transfer_screen.dart';
import '../../bills/screens/bills_screen.dart';
import '../../history/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<DashboardProvider>().fetchDashboard(),
            color: AppTheme.primaryPurple,
            backgroundColor: AppTheme.bgCard,
            child: CustomScrollView(
              slivers: [
                // ─── AppBar ─────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeader(auth),
                ),

                // ─── Carte Solde ─────────────────────────────
                SliverToBoxAdapter(
                  child: _buildBalanceCard(dashboard),
                ),

                // ─── Actions rapides ──────────────────────────
                SliverToBoxAdapter(
                  child: _buildQuickActions(),
                ),

                // ─── Dernières transactions ───────────────────
                SliverToBoxAdapter(
                  child: _buildRecentTransactions(dashboard),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── En-tête ──────────────────────────────────────────────────
  Widget _buildHeader(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour 👋',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                auth.phone ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Bouton déconnexion
          GestureDetector(
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Carte de solde ───────────────────────────────────────────
  Widget _buildBalanceCard(DashboardProvider dashboard) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withAlpha(80),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Solde disponible',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                  child: Icon(
                    _balanceVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Montant
            if (dashboard.state == DashboardState.loading)
              const SizedBox(
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _balanceVisible
                    ? Text(
                        dashboard.balance != null
                            ? CurrencyFormatter.format(dashboard.balance!)
                            : '---',
                        key: const ValueKey('visible'),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      )
                    : const Text(
                        '••••••••',
                        key: ValueKey('hidden'),
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.white54,
                          letterSpacing: 4,
                        ),
                      ),
              ),

            const SizedBox(height: 24),

            // Numéro de téléphone stylisé
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🇸🇳 Sénégal',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'XOF',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Boutons d'actions rapides ────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickActionButton(
                emoji: '📤',
                label: 'Transférer',
                color: const Color(0xFF6C63FF),
                onTap: () {
                  final dash = context.read<DashboardProvider>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ).then((_) => dash.refresh());
                },
              ),
              const SizedBox(width: 12),
              _QuickActionButton(
                emoji: '🧾',
                label: 'Payer',
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  final dash = context.read<DashboardProvider>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BillsScreen()),
                  ).then((_) => dash.refresh());
                },
              ),
              const SizedBox(width: 12),
              _QuickActionButton(
                emoji: '📋',
                label: 'Historique',
                color: const Color(0xFF10B981),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Dernières transactions ───────────────────────────────────
  Widget _buildRecentTransactions(DashboardProvider dashboard) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dernières transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (dashboard.state == DashboardState.loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: AppTheme.primaryPurple,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (dashboard.state == DashboardState.error)
            _ErrorCard(message: dashboard.errorMessage)
          else if (dashboard.recentTransactions.isEmpty)
            const _EmptyTransactions()
          else
            ...dashboard.recentTransactions
                .map((tx) => _TransactionTile(transaction: tx)),
        ],
      ),
    );
  }
}

// ─── Widget : Bouton action rapide ──────────────────────────────
class _QuickActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withAlpha(60), width: 1),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widget : Ligne de transaction ──────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.isCredit;
    final color = isCredit ? AppTheme.success : AppTheme.danger;
    final amountStr = CurrencyFormatter.formatSigned(
      transaction.netAmount,
      isCredit: isCredit,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Montant
          Text(
            amountStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Column(
        children: [
          Text('📭', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            'Aucune transaction',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String? message;

  const _ErrorCard({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Une erreur est survenue.',
              style: const TextStyle(color: AppTheme.danger, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

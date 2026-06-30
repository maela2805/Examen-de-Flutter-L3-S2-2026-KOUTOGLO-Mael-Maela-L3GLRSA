import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            onPressed: () => context.read<HistoryProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.state == HistoryState.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            );
          }

          if (provider.state == HistoryState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage ?? 'Erreur',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📭', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text(
                    'Aucune transaction',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final grouped = _groupByDate(provider.transactions);

          return RefreshIndicator(
            onRefresh: () => provider.fetchTransactions(),
            color: AppTheme.primaryPurple,
            backgroundColor: AppTheme.bgCard,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped[index];
                return _DateGroup(
                  date: entry.key,
                  transactions: entry.value,
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<MapEntry<String, List<Transaction>>> _groupByDate(
      List<Transaction> transactions) {
    final map = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final key = tx.createdAt != null
          ? DateFormatter.formatDate(tx.createdAt!)
          : 'Date inconnue';
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map.entries.toList();
  }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final List<Transaction> transactions;

  const _DateGroup({required this.date, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...transactions.map((tx) => _HistoryTile(transaction: tx)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Transaction transaction;

  const _HistoryTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.isCredit;
    final color = isCredit ? AppTheme.success : AppTheme.danger;
    final amountStr = CurrencyFormatter.formatSigned(
      transaction.netAmount,
      isCredit: isCredit,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.type.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

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
                const SizedBox(height: 3),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (transaction.createdAt != null)
                  Text(
                    DateFormatter.formatTime(transaction.createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (transaction.fees > 0)
                Text(
                  'Frais: ${CurrencyFormatter.format(transaction.fees)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/transfer_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class TransferConfirmScreen extends StatelessWidget {
  final String senderPhone;
  final String receiverPhone;
  final double amount;

  const TransferConfirmScreen({
    super.key,
    required this.senderPhone,
    required this.receiverPhone,
    required this.amount,
  });

  Future<void> _confirm(BuildContext context) async {
    final provider = context.read<TransferProvider>();
    final success = await provider.transfer(
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
      amount: amount,
    );

    if (!context.mounted) return;

    if (success) {
      context.read<DashboardProvider>().refresh();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(
          amount: amount,
          receiverPhone: receiverPhone,
          onClose: () {
            Navigator.of(context)
              ..pop() 
              ..pop() 
              ..pop(); 
          },
        ),
      );
    } else {
      String errorMessage = provider.errorMessage ?? 'Échec du transfert';
      if (errorMessage.contains('InsufficientBalanceException') ||
          errorMessage.contains('Solde insuffisant')) {
        errorMessage = 'Solde insuffisant pour effectuer ce transfert.';
      } else if (errorMessage.contains('WalletNotFoundException') ||
          errorMessage.contains('introuvable')) {
        errorMessage = 'Le numéro du destinataire n\'est pas enregistré.';
      } else {
        errorMessage = 'Une erreur est survenue lors du transfert.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Confirmer le transfert'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withAlpha(80),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text('📤', style: TextStyle(fontSize: 36)),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Vérifiez les détails',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confirmez avant d\'envoyer',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 36),

            _buildDetailCard(),

            const Spacer(),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    final double fees = (amount * 0.01).clamp(0.0, 5000.0);
    final double totalDebit = amount + fees;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'De', value: senderPhone),
          const Divider(color: AppTheme.divider, height: 16),
          _DetailRow(label: 'Vers', value: receiverPhone),
          const Divider(color: AppTheme.divider, height: 16),
          _DetailRow(
            label: 'Montant envoyé',
            value: CurrencyFormatter.format(amount),
          ),
          const Divider(color: AppTheme.divider, height: 16),
          _DetailRow(
            label: 'Frais de transfert',
            value: CurrencyFormatter.format(fees),
          ),
          const Divider(color: AppTheme.divider, height: 16),
          _DetailRow(
            label: 'Total à débiter',
            value: CurrencyFormatter.format(totalDebit),
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Consumer<TransferProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
            // Bouton Confirmer
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: provider.isLoading ? null : () => _confirm(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Confirmer le transfert',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton Annuler
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed:
                    provider.isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 15,
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppTheme.primaryPurple : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final double amount;
  final String receiverPhone;
  final VoidCallback onClose;

  const _SuccessDialog({
    required this.amount,
    required this.receiverPhone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Transfert effectué !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${CurrencyFormatter.format(amount)} envoyés\nvers $receiverPhone',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

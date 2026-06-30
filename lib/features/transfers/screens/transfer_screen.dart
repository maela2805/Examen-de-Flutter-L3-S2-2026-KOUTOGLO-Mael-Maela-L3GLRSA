import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import 'transfer_confirm_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _receiverController = TextEditingController();
  String _amountStr = '0';

  double get _amount => double.tryParse(_amountStr) ?? 0;

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == '000') {
        if (_amountStr != '0') _amountStr += '000';
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          _amountStr += key;
        }
      }
    });
  }

  void _proceed() {
    final receiver = _receiverController.text.trim();
    if (receiver.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro de destinataire invalide'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant invalide'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final double fees = (_amount * 0.01).clamp(0.0, 5000.0);
    final double totalDebit = _amount + fees;
    final double balance = context.read<DashboardProvider>().balance ?? 0.0;

    if (totalDebit > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solde insuffisant pour cette opération. Montant + frais : ${CurrencyFormatter.format(totalDebit)} (Votre solde : ${CurrencyFormatter.format(balance)})',
          ),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final senderPhone = context.read<AuthProvider>().phone!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferConfirmScreen(
          senderPhone: senderPhone,
          receiverPhone: receiver,
          amount: _amount,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _receiverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Transfert d\'argent'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  _buildReceiverField(),

                  const SizedBox(height: 36),

                  _buildAmountDisplay(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          _buildNumpad(),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SizedBox(
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
                    onTap: _proceed,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text(
                          'Continuer →',
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
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro du destinataire',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: TextField(
            controller: _receiverController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              letterSpacing: 2,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted),
              hintText: '77 000 00 00',
              hintStyle: TextStyle(color: AppTheme.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      children: [
        const Text(
          'Montant',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            CurrencyFormatter.formatNumber(int.tryParse(_amountStr) ?? 0),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
        ),
        Text(
          'XOF',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (_amount > 0) ...[
          Text(
            'Frais de transfert : ${CurrencyFormatter.format((_amount * 0.01).clamp(0.0, 5000.0))}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total à débiter de votre compte : ${CurrencyFormatter.format(_amount + (_amount * 0.01).clamp(0.0, 5000.0))}',
            style: const TextStyle(
              color: AppTheme.primaryPurple,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else
          const Text(
            'Des frais de 1% (max 5 000 XOF) s\'appliqueront en sus du montant envoyé.',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['000', '0', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => _onKeyTap(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: 60,
                        decoration: BoxDecoration(
                          color: key == '⌫'
                              ? AppTheme.danger.withAlpha(25)
                              : AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: key == '⌫'
                                ? AppTheme.danger.withAlpha(60)
                                : AppTheme.divider,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            key,
                            style: TextStyle(
                              fontSize: key == '⌫' ? 20 : 22,
                              fontWeight: FontWeight.w600,
                              color: key == '⌫'
                                  ? AppTheme.danger
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

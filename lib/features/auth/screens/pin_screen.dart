import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/screens/home_screen.dart';

class PinScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isConfirming;

  const PinScreen({
    super.key,
    required this.phoneNumber,
    this.isConfirming = false,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  final String _correctPin = '1234';
  String? _error;

  void _onKeyTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _error = null;
        _pin += value;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _error = null;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (_pin == _correctPin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _error = 'Code PIN incorrect. Réessayez.';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppTheme.primaryPurple,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.isConfirming ? 'Déverrouiller l\'application' : 'Sécurité d\'accès',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entrez votre code PIN pour ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: filled ? AppTheme.primaryPurple : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: filled ? AppTheme.primaryPurple : AppTheme.textMuted,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 24,
                child: _error != null
                    ? Text(
                        _error!,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return const SizedBox.shrink();
                    }
                    if (index == 11) {
                      return _buildKey(
                        icon: Icons.backspace_outlined,
                        onTap: _onBackspace,
                      );
                    }
                    final number = index == 10 ? '0' : '${index + 1}';
                    return _buildKey(
                      text: number,
                      onTap: () => _onKeyTap(number),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey({String? text, IconData? icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: AppTheme.textPrimary,
                size: 24,
              )
            : Text(
                text!,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
      ),
    );
  }
}

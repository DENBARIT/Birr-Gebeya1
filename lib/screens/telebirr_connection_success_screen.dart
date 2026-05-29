import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import 'kyc_profile_setup_screen.dart';

class TelebirrConnectionSuccessScreen extends StatelessWidget {
  final String telebirrNumber;

  const TelebirrConnectionSuccessScreen({
    super.key,
    required this.telebirrNumber,
  });

  String _formatNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return value;
    final safeDigits = digits.padRight(4, '0');
    return '+251 ${safeDigits.substring(0, 1)}XX XXX ${safeDigits.substring(safeDigits.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber = _formatNumber(telebirrNumber);

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Connection Successful',
          style: BirrTheme.getHeadlineLgMobile(
            context,
          ).copyWith(color: BirrTheme.primary, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 144,
                      height: 144,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BirrTheme.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BirrTheme.primary.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: BirrTheme.primary,
                        size: 68,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),
              Text(
                'Telebirr connected',
                textAlign: TextAlign.center,
                style: BirrTheme.getHeadlineLg(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: BirrTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  displayNumber,
                  style: BirrTheme.getBodyLg(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: BirrTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Your Telebirr wallet is now linked. Complete your profile next so we can activate your investment account.',
                  textAlign: TextAlign.center,
                  style: BirrTheme.getBodyMd(
                    context,
                  ).copyWith(color: BirrTheme.onSurfaceVariant, height: 1.45),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const KycProfileSetupScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BirrTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Complete Your Profile',
                    style: BirrTheme.getHeadlineMdMobile(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

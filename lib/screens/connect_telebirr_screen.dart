import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_system.dart';
import '../models/app_state.dart';
import 'telebirr_connection_success_screen.dart';

class ConnectTelebirrScreen extends StatefulWidget {
  final String phoneNumber;

  const ConnectTelebirrScreen({super.key, required this.phoneNumber});

  @override
  State<ConnectTelebirrScreen> createState() => _ConnectTelebirrScreenState();
}

class _ConnectTelebirrScreenState extends State<ConnectTelebirrScreen> {
  final TextEditingController _telebirrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Prefill user's onboarding number (without prefix)
    final parts = widget.phoneNumber.split(' ');
    if (parts.length > 1) {
      _telebirrController.text = parts[1];
    }
  }

  @override
  void dispose() {
    _telebirrController.dispose();
    super.dispose();
  }

  void _connectWallet() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate connection delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });
        }
      });
    }
  }

  void _proceedToKYC() {
    final fullNumber = '+251 ${_telebirrController.text.trim()}';
    // Save to global app state
    Provider.of<AppState>(context, listen: false).connectTelebirr(fullNumber);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TelebirrConnectionSuccessScreen(telebirrNumber: fullNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BirrTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wallet Connection',
          style: BirrTheme.getHeadlineLgMobile(
            context,
          ).copyWith(color: BirrTheme.primary, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 120,
              child: _isSuccess ? _buildSuccessState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12.0),
          Center(
            child: Column(
              children: [
                Text(
                  'Connect your Telebirr wallet',
                  style: BirrTheme.getHeadlineMd(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Link your mobile wallet to start investing in government securities.',
                  textAlign: TextAlign.center,
                  style: BirrTheme.getBodyMd(
                    context,
                  ).copyWith(color: BirrTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Asymmetric Bento-style visual panel
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: BirrTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: BirrTheme.outlineVariant),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            BirrTheme.primaryContainer.withValues(alpha: 0.2),
                            BirrTheme.secondaryContainer.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BirrTheme.outlineVariant),
                    boxShadow: BirrTheme.softShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 48,
                        color: BirrTheme.primary,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'TELEBIRR',
                        style: BirrTheme.getLabelBold(context).copyWith(
                          fontSize: 11,
                          letterSpacing: 2.0,
                          color: BirrTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28.0),

          // Phone Input
          Text(
            'Your Telebirr Phone Number',
            style: BirrTheme.getLabelBold(
              context,
            ).copyWith(color: BirrTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BirrTheme.outlineVariant),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+251',
                  style: BirrTheme.getBodyLg(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: BirrTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  controller: _telebirrController,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Telebirr phone number';
                    }
                    if (value.length < 9) {
                      return 'Enter a valid 9-digit number';
                    }
                    return null;
                  },
                  style: BirrTheme.getBodyLg(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: '9XX XXX XXX',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          Row(
            children: [
              const Icon(Icons.info, size: 16, color: BirrTheme.primary),
              const SizedBox(width: 6.0),
              Text(
                'Your investments will be funded from this wallet',
                style: BirrTheme.getLabelMd(
                  context,
                ).copyWith(color: BirrTheme.onSurfaceVariant),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _connectWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: BirrTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Connect Wallet',
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
    );
  }

  Widget _buildSuccessState() {
    final rawNum = _telebirrController.text.trim();
    final safeRaw = rawNum.length >= 4 ? rawNum : rawNum.padRight(4, '0');
    final obfuscatedNum =
        '+251 ${safeRaw.substring(0, 1)}XX XXX ${safeRaw.substring(safeRaw.length - 3)}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // Dynamic green checkmark circle
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BirrTheme.primary.withValues(alpha: 0.08),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BirrTheme.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: BirrTheme.primary,
                  size: 64,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32.0),

        Text(
          'Wallet connected',
          style: BirrTheme.getHeadlineLg(
            context,
          ).copyWith(color: BirrTheme.primary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12.0),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: BirrTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(
            obfuscatedNum,
            style: BirrTheme.getBodyLg(context).copyWith(
              fontWeight: FontWeight.bold,
              color: BirrTheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 24.0),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "You're all set! You can now use your Telebirr balance to invest in high-yield money market pools.",
            textAlign: TextAlign.center,
            style: BirrTheme.getBodyMd(
              context,
            ).copyWith(color: BirrTheme.onSurfaceVariant, height: 1.4),
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _proceedToKYC,
            style: ElevatedButton.styleFrom(
              backgroundColor: BirrTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continue',
              style: BirrTheme.getHeadlineMdMobile(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

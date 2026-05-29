import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/design_system.dart';

/// What the entered code is being verified for.
enum OtpPurpose { signup, recovery, sms }

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String contactValue;
  final String channel;
  final String initialOtp;
  final String authEmail;
  final String password;
  final bool isPasswordReset;
  final OtpPurpose purpose;
  final bool autoFillOtp;
  final Future<bool> Function(String otp)? onVerifyOtp;
  final Future<void> Function()? onResendOtp;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.contactValue,
    required this.channel,
    required this.initialOtp,
    required this.authEmail,
    required this.password,
    required this.isPasswordReset,
    required this.purpose,
    this.autoFillOtp = false,
    this.onVerifyOtp,
    this.onResendOtp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final AuthService _auth = AuthService();

  int _secondsRemaining = 45;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-fill the OTP if provided (for dev/demo convenience)
    if (widget.autoFillOtp && widget.initialOtp.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = widget.initialOtp[i];
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 45;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  String get _collectedOtp => _controllers.map((c) => c.text).join();

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: BirrTheme.error),
    );
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    try {
      switch (widget.purpose) {
        case OtpPurpose.signup:
          await _auth.resendEmailSignupOtp(email: widget.email);
          break;
        case OtpPurpose.recovery:
          await _auth.sendPasswordResetOtp(email: widget.email);
          break;
        case OtpPurpose.sms:
          await _auth.resendSmsOtp(phone: widget.phoneNumber);
          break;
      }
      _startTimer();
      final fallbackEmail = dotenv.env['TEST_OTP_EMAIL'] ?? '';
      final sentTo = widget.channel == 'email'
          ? (widget.email.isNotEmpty
                ? widget.email
                : (widget.contactValue.isNotEmpty
                      ? widget.contactValue
                      : fallbackEmail))
          : (widget.phoneNumber.isNotEmpty
                ? widget.phoneNumber
                : widget.contactValue);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A new verification code has been sent to $sentTo'),
          backgroundColor: BirrTheme.primaryContainer,
        ),
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Could not resend the code. Please try again.');
    }
  }

  Future<void> _verify() async {
    if (_isVerifying) return;

    final otp = _collectedOtp;
    if (otp.length < 6) {
      _showError('Please enter all 6 digits of the verification code');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      switch (widget.purpose) {
        case OtpPurpose.signup:
          await _auth.verifyEmailSignup(email: widget.email, token: otp);
          break;
        case OtpPurpose.recovery:
          await _auth.verifyPasswordReset(email: widget.email, token: otp);
          break;
        case OtpPurpose.sms:
          await _auth.verifySmsOtp(phone: widget.phoneNumber, token: otp);
          break;
      }
      // Verified — a real session now exists.
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      _showError(e.message);
      _clearInputs();
    } catch (e) {
      _showError('Verification failed. Please check the code and try again.');
      _clearInputs();
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _clearInputs() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackEmail = dotenv.env['TEST_OTP_EMAIL'] ?? '';
    final displayContact = widget.channel == 'email'
        ? (widget.email.isNotEmpty
              ? widget.email
              : (widget.contactValue.isNotEmpty
                    ? widget.contactValue
                    : fallbackEmail))
        : (widget.phoneNumber.isNotEmpty
              ? widget.phoneNumber
              : widget.contactValue);

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BirrTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Verification',
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
              const SizedBox(height: 24.0),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: BirrTheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open,
                    size: 40,
                    color: BirrTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              Text(
                'Enter verification code',
                style: BirrTheme.getHeadlineLgMobile(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'We sent a 6-digit code to $displayContact',
                textAlign: TextAlign.center,
                style: BirrTheme.getBodyMd(
                  context,
                ).copyWith(color: BirrTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      enabled: !_isVerifying,
                      style: BirrTheme.getHeadlineMd(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                            _verify();
                          }
                        } else {
                          if (index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: BirrTheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: BirrTheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32.0),
              Column(
                children: [
                  if (!_canResend)
                    Text(
                      'Resend in 0:${_secondsRemaining < 10 ? '0' : ''}$_secondsRemaining',
                      style: BirrTheme.getLabelMd(
                        context,
                      ).copyWith(color: BirrTheme.onSurfaceVariant),
                    ),
                  if (_canResend)
                    Text(
                      "Didn't receive a code?",
                      style: BirrTheme.getLabelMd(context),
                    ),
                  const SizedBox(height: 6.0),
                  TextButton(
                    onPressed: _canResend && !_isVerifying ? _resendCode : null,
                    style: TextButton.styleFrom(
                      foregroundColor: BirrTheme.secondary,
                    ),
                    child: Text(
                      'Resend Code',
                      style: BirrTheme.getLabelBold(context).copyWith(
                        color: _canResend
                            ? BirrTheme.secondary
                            : BirrTheme.secondary.withValues(alpha: 0.4),
                        decoration: _canResend
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BirrTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Verify',
                          style: BirrTheme.getHeadlineMdMobile(context)
                              .copyWith(
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

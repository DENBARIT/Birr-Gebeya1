import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String contactValue;
  final String channel;
  final String initialOtp;
  final String authEmail;
  final String password;
  final bool isPasswordReset;

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

  int _secondsRemaining = 45;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-fill the OTP if provided (for dev/demo convenience)
    if (widget.initialOtp.length == 6) {
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

  void _resendCode() {
    if (_canResend) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code has been sent!'),
          backgroundColor: BirrTheme.primaryContainer,
        ),
      );
    }
  }

  void _verify() {
    String otp = '';
    for (var controller in _controllers) {
      otp += controller.text;
    }

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the verification code'),
          backgroundColor: BirrTheme.error,
        ),
      );
      return;
    }

    // In demo mode accept any 6-digit code (or the pre-filled initialOtp)
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final displayContact = widget.channel == 'email'
        ? widget.email.isNotEmpty
              ? widget.email
              : widget.contactValue
        : widget.phoneNumber.isNotEmpty
        ? widget.phoneNumber
        : widget.contactValue;

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
                'Sent to $displayContact',
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
                    onPressed: _canResend ? _resendCode : null,
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
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BirrTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Verify',
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

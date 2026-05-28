import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../theme/design_system.dart';
import '../widgets/brand_logo.dart';
import 'connect_telebirr_screen.dart';
import 'dashboard_screen.dart';
import 'otp_verification_screen.dart';
import 'splash_screen.dart';

enum AuthAction { signIn, signUp, resetPassword }

enum AuthMethod { phone, email }

class PhoneAuthScreen extends StatefulWidget {
  final AuthAction initialAction;
  final AuthMethod initialMethod;

  const PhoneAuthScreen({
    super.key,
    this.initialAction = AuthAction.signUp,
    this.initialMethod = AuthMethod.phone,
  });

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  late AuthAction _authAction;
  late AuthMethod _authMethod;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _authAction = widget.initialAction;
    _authMethod =
        _authAction == AuthAction.signIn ||
            _authAction == AuthAction.resetPassword
        ? AuthMethod.email
        : widget.initialMethod;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _buildDisplayName(String contactValue) {
    if (_authMethod == AuthMethod.email) {
      return contactValue.split('@').first;
    }
    final digitsOnly = contactValue.replaceAll(RegExp(r'\D'), '');
    final tail = digitsOnly.length <= 4
        ? digitsOnly
        : digitsOnly.substring(digitsOnly.length - 4);
    return 'User $tail';
  }

  void _startPasswordReset() {
    setState(() {
      _authAction = AuthAction.resetPassword;
      _authMethod = AuthMethod.email;
      _phoneController.clear();
      _passwordController.clear();
      _obscurePassword = true;
    });
  }

  void _backToSignIn() {
    setState(() {
      _authAction = AuthAction.signIn;
      _authMethod = AuthMethod.email;
      _phoneController.clear();
      _passwordController.clear();
      _obscurePassword = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final contactValue = _authMethod == AuthMethod.phone
        ? '+251 ${_phoneController.text.trim()}'
        : _emailController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      if (_authAction == AuthAction.signUp) {
        final isEmail = _authMethod == AuthMethod.email;
        // Supabase phone OTP requires E.164 with no spaces (e.g. +2519XXXXXXXX).
        final e164Phone = contactValue.replaceAll(' ', '');

        // Ask Supabase to send a real OTP (e-mail confirmation code, or SMS).
        if (isEmail) {
          await _auth.sendEmailSignupOtp(
            email: contactValue,
            password: _passwordController.text.trim(),
          );
        } else {
          await _auth.sendSmsOtp(phone: e164Phone);
        }

        if (!mounted) return;

        final otpResult = await Navigator.of(context).push<bool?>(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: isEmail ? '' : e164Phone,
              email: isEmail ? contactValue : '',
              contactValue: contactValue,
              channel: isEmail ? 'email' : 'phone',
              purpose: isEmail ? OtpPurpose.signup : OtpPurpose.sms,
            ),
          ),
        );

        if (otpResult != true) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }

        if (!mounted) return;

        // Session now exists — persist the profile row to Supabase.
        final appState = context.read<AppState>();
        await appState.updateProfile(
          userName: _buildDisplayName(contactValue),
          fullNameValue: _buildDisplayName(contactValue),
          telebirrNumberValue: isEmail ? null : contactValue,
          email: isEmail ? contactValue : null,
          phoneNumber: isEmail ? null : contactValue,
        );

        if (!mounted) return;

        if (_authMethod == AuthMethod.phone) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ConnectTelebirrScreen(phoneNumber: contactValue),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppNavigationShell()),
            (route) => false,
          );
        }
        return;
      }

      if (_authAction == AuthAction.resetPassword) {
        final email = _emailController.text.trim();

        // Send a real password-recovery code.
        await _auth.sendPasswordResetOtp(email: email);

        if (!mounted) return;

        final otpResult = await Navigator.of(context).push<bool?>(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: '',
              email: email,
              contactValue: email,
              channel: 'email',
              purpose: OtpPurpose.recovery,
            ),
          ),
        );

        if (otpResult != true) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }

        // Recovery verified -> a session exists; collect and set new password.
        if (!mounted) return;
        final newPassword = await _promptNewPassword();
        if (newPassword == null) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }

        await _auth.updatePassword(newPassword: newPassword);
        await _auth.signOut();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully. Please sign in.'),
            backgroundColor: BirrTheme.primary,
          ),
        );
        _backToSignIn();
        return;
      }

      // Sign In — real e-mail + password authentication.
      await _auth.signInWithPassword(
        email: contactValue,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: BirrTheme.primary,
        ),
      );

      await context.read<AppState>().refreshFromSupabase();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppNavigationShell()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: BirrTheme.error,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: BirrTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Collects a new password after a verified recovery code.
  Future<String?> _promptNewPassword() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Set a new password'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  autofocus: true,
                  validator: (value) {
                    final password = value?.trim() ?? '';
                    if (password.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'New password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setLocalState(() => obscure = !obscure),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop(controller.text.trim());
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSegmentedButton({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? BirrTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : BirrTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: BirrTheme.getLabelBold(context).copyWith(
                  color: selected ? Colors.white : BirrTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 34, showLabel: false, showGlow: false),
            const SizedBox(width: 10),
            Text(
              'ብር Gebeya',
              style: BirrTheme.getHeadlineLgMobile(
                context,
              ).copyWith(color: BirrTheme.primary, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BirrTheme.primary.withValues(alpha: 0.05),
                          ),
                        ),
                        Container(
                          width: 122,
                          height: 122,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BirrTheme.secondaryContainer.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                        const BrandLogo(size: 128),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    _authAction == AuthAction.signIn
                        ? 'Sign in to your account'
                        : _authAction == AuthAction.resetPassword
                        ? 'Reset your password'
                        : 'Enter your credentials',
                    style: BirrTheme.getHeadlineLg(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _authAction == AuthAction.signIn
                        ? 'Use the email address and password you already created.'
                        : _authAction == AuthAction.resetPassword
                        ? 'Verify your email with a one-time code and set a new password.'
                        : 'Create your account and verify it with a one-time code.',
                    style: BirrTheme.getBodyMd(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant, height: 1.4),
                  ),
                  if (_authAction == AuthAction.signIn) ...[
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _startPasswordReset,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  ],
                  if (_authAction == AuthAction.resetPassword) ...[
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _backToSignIn,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to sign in'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, BirrTheme.surfaceContainerLow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: BirrTheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: BirrTheme.primary.withValues(alpha: 0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _authAction == AuthAction.signIn
                              ? 'Welcome back'
                              : _authAction == AuthAction.resetPassword
                              ? 'Secure your account'
                              : 'Create your account',
                          style: BirrTheme.getLabelBold(
                            context,
                          ).copyWith(color: BirrTheme.secondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _authAction == AuthAction.signIn
                              ? 'Use the logo-inspired sign-in flow with a polished, calm experience.'
                              : _authAction == AuthAction.resetPassword
                              ? 'We will verify your email and help you set a new password.'
                              : 'Join Birr Gebeya and verify your profile in a few quick steps.',
                          style: BirrTheme.getBodyMd(context).copyWith(
                            color: BirrTheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  if (_authAction == AuthAction.signUp) ...[
                    const SizedBox(height: 16.0),
                    Text(
                      'Verification Method',
                      style: BirrTheme.getLabelBold(
                        context,
                      ).copyWith(color: BirrTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: BirrTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: BirrTheme.outlineVariant),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildSegmentedButton(
                            selected: _authMethod == AuthMethod.phone,
                            icon: Icons.phone_android,
                            label: 'Mobile Number',
                            onTap: () {
                              setState(() => _authMethod = AuthMethod.phone);
                            },
                          ),
                          _buildSegmentedButton(
                            selected: _authMethod == AuthMethod.email,
                            icon: Icons.alternate_email,
                            label: 'Email',
                            onTap: () {
                              setState(() => _authMethod = AuthMethod.email);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  Text(
                    _authMethod == AuthMethod.phone ? 'Mobile Number' : 'Email',
                    style: BirrTheme.getLabelBold(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8.0),
                  if (_authAction == AuthAction.signUp &&
                      _authMethod == AuthMethod.phone)
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
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 9,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 9) {
                                return 'Enter a valid 9-digit number';
                              }
                              if (!value.startsWith('9')) {
                                return 'Should start with 9';
                              }
                              return null;
                            },
                            style: BirrTheme.getBodyLg(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                              hintText: '9XX XXX XXX',
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 18.0,
                              ),
                              hintStyle: TextStyle(color: Color(0x993F4944)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Please enter your email';
                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );
                        if (!emailRegex.hasMatch(email)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      style: BirrTheme.getBodyLg(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'you@example.com',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 18.0,
                        ),
                        hintStyle: TextStyle(color: Color(0x993F4944)),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  if (_authAction != AuthAction.resetPassword) ...[
                    Text(
                      'Password',
                      style: BirrTheme.getLabelBold(
                        context,
                      ).copyWith(color: BirrTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        final password = value?.trim() ?? '';
                        if (password.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (password.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      style: BirrTheme.getBodyLg(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 18.0,
                        ),
                        hintStyle: const TextStyle(color: Color(0x993F4944)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: BirrTheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: BirrTheme.primary,
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          _authAction == AuthAction.signIn
                              ? 'Enter your email and password to sign in.'
                              : _authAction == AuthAction.resetPassword
                              ? 'Use the code sent to your email, then create a new password.'
                              : 'Send a verification code to continue your sign-up.',
                          style: BirrTheme.getLabelMd(
                            context,
                          ).copyWith(color: BirrTheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BirrTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _authAction == AuthAction.signIn
                                  ? 'Sign In'
                                  : _authAction == AuthAction.resetPassword
                                  ? 'Send reset code'
                                  : 'Send verification code',
                              style: BirrTheme.getHeadlineMdMobile(context)
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_authAction == AuthAction.signUp)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _authAction = AuthAction.signIn;
                            _authMethod = AuthMethod.email;
                          });
                        },
                        child: Text(
                          'Already have an account? Sign in',
                          style: BirrTheme.getBodyMd(context).copyWith(
                            color: BirrTheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

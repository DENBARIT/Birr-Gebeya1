import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_system.dart';
import '../models/app_state.dart';
import 'dashboard_screen.dart';

class KycProfileSetupScreen extends StatefulWidget {
  const KycProfileSetupScreen({super.key});

  @override
  State<KycProfileSetupScreen> createState() => _KycProfileSetupScreenState();
}

class _KycProfileSetupScreenState extends State<KycProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "Abebe");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tinController = TextEditingController();

  bool _confirmAccurate = false;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _tinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_confirmAccurate || !_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the compliance statements and terms'),
            backgroundColor: BirrTheme.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Update name in global state
      Provider.of<AppState>(context, listen: false).userName = _nameController.text.trim();

      // Simulate network save
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Clear all routes and push DashboardShell
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AppNavigationShell()),
            (route) => false,
          );
        }
      });
    }
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
          'Profile Setup',
          style: BirrTheme.getHeadlineLgMobile(context).copyWith(
            color: BirrTheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),
                  Text(
                    'KYC Profile Setup',
                    style: BirrTheme.getHeadlineLg(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'As regulated by the National Bank of Ethiopia, we require these details to activate your investment portfolio.',
                    style: BirrTheme.getBodyMd(context).copyWith(
                      color: BirrTheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 28.0),
                  
                  // Full Name
                  Text(
                    'Full Name (as per official ID)',
                    style: BirrTheme.getLabelBold(context).copyWith(
                      color: BirrTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    style: BirrTheme.getBodyLg(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                    ),
                  ),
                  
                  const SizedBox(height: 20.0),
                  
                  // Email
                  Text(
                    'Email Address',
                    style: BirrTheme.getLabelBold(context).copyWith(
                      color: BirrTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    style: BirrTheme.getBodyLg(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                    ),
                  ),
                  
                  const SizedBox(height: 20.0),
                  
                  // TIN
                  Text(
                    'Taxpayer Identification Number (TIN) - Optional',
                    style: BirrTheme.getLabelBold(context).copyWith(
                      color: BirrTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _tinController,
                    keyboardType: TextInputType.number,
                    style: BirrTheme.getBodyLg(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: '10-digit TIN (optional)',
                    ),
                  ),
                  
                  const SizedBox(height: 28.0),
                  
                  // Checkbox 1: Accuracy Statement
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _confirmAccurate,
                        activeColor: BirrTheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _confirmAccurate = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _confirmAccurate = !_confirmAccurate),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'I confirm that the details provided are accurate and match my official government-issued ID.',
                              style: BirrTheme.getBodyMd(context).copyWith(
                                color: BirrTheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // Checkbox 2: Terms & Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: BirrTheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _agreeTerms = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'I agree to the Terms & Conditions and Privacy Policy governing government securities investments.',
                              style: BirrTheme.getBodyMd(context).copyWith(
                                color: BirrTheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40.0),
                  
                  // Action complete setup
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
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
                              'Complete Setup',
                              style: BirrTheme.getHeadlineMdMobile(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

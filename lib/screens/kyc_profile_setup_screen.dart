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
  final TextEditingController _nameController = TextEditingController(
    text: 'Abebe',
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDob;
  bool _confirmAccurate = false;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final today = DateTime.now();
    final initialDate =
        _selectedDob ?? DateTime(today.year - 18, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year - 13, today.month, today.day),
      helpText: 'Select date of birth',
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = _formatDob(picked);
      });
    }
  }

  String _formatDob(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null || _selectedDob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your gender and date of birth'),
            backgroundColor: BirrTheme.error,
          ),
        );
        return;
      }

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

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      await Provider.of<AppState>(context, listen: false).updateProfile(
        userName: name,
        fullNameValue: name,
        genderValue: _selectedGender,
        dateOfBirthValue: _selectedDob,
        email: email,
      );

      // Simulate network save
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Capture the app-level messenger before navigating so the snackbar
          // survives the route replacement and shows on the dashboard.
          final messenger = ScaffoldMessenger.of(context);

          // Clear all routes and push DashboardShell
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AppNavigationShell()),
            (route) => false,
          );

          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Sign up successfully'),
                backgroundColor: BirrTheme.primary,
              ),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),
                  Text(
                    'KYC Profile Setup',
                    style: BirrTheme.getHeadlineLg(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'We require these details to activate your investment portfolio.',
                    style: BirrTheme.getBodyMd(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant, height: 1.4),
                  ),

                  const SizedBox(height: 28.0),

                  Text(
                    'Full Name',
                    style: BirrTheme.getLabelBold(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant),
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
                    style: BirrTheme.getBodyLg(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  Text(
                    'Email',
                    style: BirrTheme.getLabelBold(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant),
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
                    style: BirrTheme.getBodyLg(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  Text(
                    'Gender',
                    style: BirrTheme.getLabelBold(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(
                        value: 'Prefer not to say',
                        child: Text('Prefer not to say'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Select gender',
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  Text(
                    'Date of Birth',
                    style: BirrTheme.getLabelBold(
                      context,
                    ).copyWith(color: BirrTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    readOnly: true,
                    controller: _dobController,
                    onTap: _pickDob,
                    validator: (value) {
                      if (_selectedDob == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                    style: BirrTheme.getBodyLg(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: Icon(Icons.calendar_month_outlined),
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
                          onTap: () => setState(
                            () => _confirmAccurate = !_confirmAccurate,
                          ),
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
                          onTap: () =>
                              setState(() => _agreeTerms = !_agreeTerms),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Complete Setup',
                              style: BirrTheme.getHeadlineMdMobile(context)
                                  .copyWith(
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

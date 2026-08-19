import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../widgets/brand_logo.dart';
import 'phone_auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BirrTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandLogo(
                        size: 172,
                        showLabel: false,
                        circular: true,
                        glimmer: true,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Grow your money with Ethiopian Treasury Bills',
                        textAlign: TextAlign.center,
                        style: BirrTheme.getBodyLg(context).copyWith(
                          color: BirrTheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhoneAuthScreen(),
                          ),
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
                        'Get Started',
                        style: BirrTheme.getHeadlineMdMobile(context)
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneAuthScreen(
                            initialAction: AuthAction.signIn,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: BirrTheme.primary,
                    ),
                    child: Text(
                      'Already have an account? Sign in',
                      style: BirrTheme.getBodyLg(context).copyWith(
                        color: BirrTheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 16,
                        color: BirrTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Regulated by National Bank of Ethiopia',
                        style: BirrTheme.getLabelMd(context),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

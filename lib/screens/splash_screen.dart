import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'phone_auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BirrTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Atmospheric subtle tonal gradient in background
            Positioned(
              top: -150,
              left: 0,
              right: 0,
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.8,
                    colors: [
                      const Color(0xFFA0F3D4).withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content layout
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Visual Branding
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer decorative ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BirrTheme.primaryContainer.withValues(
                                  alpha: 0.12,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Inner card
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: BirrTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: BirrTheme.primaryContainer.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'ብር Gebeya',
                        style: BirrTheme.getHeadlineLgMobile(context).copyWith(
                          color: BirrTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
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

                  const Spacer(flex: 2),

                  // Middle section image simulation placeholder
                  Container(
                    width: double.infinity,
                    height: 170,
                    decoration: BoxDecoration(
                      color: BirrTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: BirrTheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Soft green abstract dashboard display
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  BirrTheme.primary.withValues(alpha: 0.05),
                                  BirrTheme.secondary.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        // Inner chart mock design graphics
                        Center(
                          child: Icon(
                            Icons.trending_up,
                            size: 64,
                            color: BirrTheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        // Title/Labels inside visual container
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secure yield rates up to 10.5%',
                                style: BirrTheme.getLabelBold(
                                  context,
                                ).copyWith(color: BirrTheme.primary),
                              ),
                              Text(
                                'Guaranteed by the Government of Ethiopia',
                                style: BirrTheme.getLabelMd(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Actions & Compliance
                  Column(
                    children: [
                      // Get Started Primary Action
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

                      // Secondary Navigation Action
                      TextButton(
                        onPressed: () {
                          // For prototype convenience, let's also bypass directly to the login flow
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhoneAuthScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: BirrTheme.primary,
                        ),
                        child: Text(
                          'I already have an account',
                          style: BirrTheme.getBodyLg(context).copyWith(
                            color: BirrTheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Compliance Footer
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
          ],
        ),
      ),
    );
  }
}

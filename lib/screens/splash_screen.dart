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
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -90,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BirrTheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 70,
              right: -70,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BirrTheme.secondaryContainer.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: 110,
              left: -80,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BirrTheme.primaryContainer.withValues(alpha: 0.06),
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
                      const BrandLogo(size: 172),
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
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, BirrTheme.surfaceContainerLow],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: BirrTheme.outlineVariant.withValues(alpha: 0.7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: BirrTheme.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -60,
                          left: -40,
                          child: _GlowOrb(
                            size: 150,
                            color: BirrTheme.primary.withValues(alpha: 0.08),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          right: -30,
                          child: _GlowOrb(
                            size: 130,
                            color: BirrTheme.secondaryContainer.withValues(
                              alpha: 0.16,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const BrandLogo(size: 92, showLabel: false),
                              const SizedBox(height: 10),
                              Text(
                                'A warmer way to grow savings',
                                style: BirrTheme.getHeadlineMdMobile(context)
                                    .copyWith(
                                      color: BirrTheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
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

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 28, spreadRadius: 6)],
      ),
    );
  }
}

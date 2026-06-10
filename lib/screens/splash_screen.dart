// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';

// import '../theme/design_system.dart';
// import '../widgets/brand_logo.dart';
// import 'phone_auth_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final VideoPlayerController _videoController;
//   late final Future<void> _videoInitialize;

//   @override
//   void initState() {
//     super.initState();
//     _videoController = VideoPlayerController.asset('lib/assets/video.mp4')
//       ..setLooping(true)
//       ..setVolume(0.0);
//     _videoInitialize = _videoController.initialize().then((_) {
//       if (!mounted) return;
//       _videoController.play();
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _videoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: BirrTheme.background,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned(
//               top: -120,
//               left: -90,
//               child: Container(
//                 width: 220,
//                 height: 220,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: BirrTheme.primary.withValues(alpha: 0.08),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 70,
//               right: -70,
//               child: Container(
//                 width: 170,
//                 height: 170,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: BirrTheme.secondaryContainer.withValues(alpha: 0.18),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 110,
//               left: -80,
//               child: Container(
//                 width: 190,
//                 height: 190,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: BirrTheme.primaryContainer.withValues(alpha: 0.06),
//                 ),
//               ),
//             ),
//             SingleChildScrollView(
//               physics: const ClampingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20.0,
//                   vertical: 16.0,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(height: 40),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const BrandLogo(size: 172),
//                         const SizedBox(height: 8.0),
//                         Text(
//                           'Grow your money with Ethiopian Treasury Bills',
//                           textAlign: TextAlign.center,
//                           style: BirrTheme.getBodyLg(context).copyWith(
//                             color: BirrTheme.onSurfaceVariant,
//                             height: 1.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 32),
//                     Container(
//                       width: double.infinity,
//                       height: 230,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Colors.white,
//                             BirrTheme.surfaceContainerLow,
//                             BirrTheme.primaryContainer.withValues(alpha: 0.16),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(28),
//                         border: Border.all(
//                           color: BirrTheme.outlineVariant.withValues(
//                             alpha: 0.55,
//                           ),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: BirrTheme.primary.withValues(alpha: 0.08),
//                             blurRadius: 26,
//                             offset: const Offset(0, 12),
//                           ),
//                         ],
//                       ),
//                       clipBehavior: Clip.antiAlias,
//                       child: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Positioned(
//                             top: -60,
//                             left: -40,
//                             child: _GlowOrb(
//                               size: 150,
//                               color: BirrTheme.primary.withValues(alpha: 0.08),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: -50,
//                             right: -30,
//                             child: _GlowOrb(
//                               size: 130,
//                               color: BirrTheme.secondaryContainer.withValues(
//                                 alpha: 0.16,
//                               ),
//                             ),
//                           ),
//                           Positioned.fill(
//                             child: FutureBuilder<void>(
//                               future: _videoInitialize,
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState !=
//                                         ConnectionState.done ||
//                                     !_videoController.value.isInitialized) {
//                                   return const Center(
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.2,
//                                     ),
//                                   );
//                                 }

//                                 return FittedBox(
//                                   fit: BoxFit.cover,
//                                   child: SizedBox(
//                                     width: _videoController.value.size.width,
//                                     height: _videoController.value.size.height,
//                                     child: VideoPlayer(_videoController),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           Positioned.fill(
//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.white.withValues(alpha: 0.02),
//                                     BirrTheme.primary.withValues(alpha: 0.06),
//                                     BirrTheme.background.withValues(
//                                       alpha: 0.12,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     Column(
//                       children: [
//                         SizedBox(
//                           width: double.infinity,
//                           height: 56,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const PhoneAuthScreen(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: BirrTheme.primary,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               'Get Started',
//                               style: BirrTheme.getHeadlineMdMobile(context)
//                                   .copyWith(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12.0),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const PhoneAuthScreen(
//                                   initialAction: AuthAction.signIn,
//                                 ),
//                               ),
//                             );
//                           },
//                           style: TextButton.styleFrom(
//                             foregroundColor: BirrTheme.primary,
//                           ),
//                           child: Text(
//                             'Already have an account? Sign in',
//                             style: BirrTheme.getBodyLg(context).copyWith(
//                               color: BirrTheme.primary,
//                               fontWeight: FontWeight.w600,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16.0),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.verified_user,
//                               size: 16,
//                               color: BirrTheme.onSurfaceVariant,
//                             ),
//                             const SizedBox(width: 6.0),
//                             Text(
//                               'Regulated by National Bank of Ethiopia',
//                               style: BirrTheme.getLabelMd(context),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _GlowOrb extends StatelessWidget {
//   final double size;
//   final Color color;

//   const _GlowOrb({required this.size, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color,
//         boxShadow: [BoxShadow(color: color, blurRadius: 28, spreadRadius: 6)],
//       ),
//     );
//   }
// }

// class _ZigZagLinePainter extends CustomPainter {
//   final double progress;
//   final Color color;

//   const _ZigZagLinePainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;
//     final basePaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round
//       ..color = color.withValues(alpha: 0.15);

//     final movingPaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.5
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round
//       ..shader = LinearGradient(
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//         colors: [
//           color.withValues(alpha: 0.05),
//           color,
//           color.withValues(alpha: 0.85),
//           color.withValues(alpha: 0.05),
//         ],
//         stops: [
//           0.0,
//           (progress * 0.45).clamp(0.18, 0.45),
//           (progress * 0.45 + 0.22).clamp(0.38, 0.75),
//           1.0,
//         ],
//       ).createShader(rect);

//     Path buildPath(double phaseShift) {
//       final path = Path();
//       final amplitude = size.height * 0.23;
//       final centerY = size.height / 2;
//       const step = 28.0;
//       final startX = -step + phaseShift;
//       var firstPoint = true;
//       for (double x = startX; x <= size.width + step; x += step / 2) {
//         final y = ((x / (step / 2)).floor().isEven
//             ? centerY - amplitude
//             : centerY + amplitude);
//         if (firstPoint) {
//           path.moveTo(x, y);
//           firstPoint = false;
//         } else {
//           path.lineTo(x, y);
//         }
//       }
//       return path;
//     }

//     final offset = (progress * 56) % 28;
//     canvas.drawPath(buildPath(0), basePaint);
//     canvas.drawPath(buildPath(offset), movingPaint);
//   }

//   @override
//   bool shouldRepaint(covariant _ZigZagLinePainter oldDelegate) {
//     return oldDelegate.progress != progress || oldDelegate.color != color;
//   }
// }
import 'package:flutter/material.dart';
// 1. Official dotLottie engine package
import 'package:dotlottie_flutter/dotlottie_flutter.dart';

import '../theme/design_system.dart';
import '../widgets/brand_logo.dart';
import 'phone_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
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
                    const SizedBox(height: 32),

                    // --- THE CARD WITH ANIMATION STARTS HERE ---
                    Container(
                      width: double.infinity,
                      height: 230,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            BirrTheme.surfaceContainerLow,
                            BirrTheme.primaryContainer.withValues(alpha: 0.16),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: BirrTheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: BirrTheme.primary.withValues(alpha: 0.08),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
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

                          // DotLottieView widget rendering the local asset.
                          // NOTE: dotlottie_flutter internally prepends
                          // 'assets/' via rootBundle.load('assets/$source'),
                          // so the source must be the path RELATIVE to the
                          // assets/ folder (i.e. without the 'assets/' prefix).
                          Positioned.fill(
                            child: DotLottieView(
                              source: 'investment_animation.lottie',
                              sourceType: 'asset',
                              autoplay: true,
                              loop: true,
                              fit: BoxFit.contain,
                            ),
                          ),

                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.02),
                                    BirrTheme.primary.withValues(alpha: 0.06),
                                    BirrTheme.background.withValues(
                                      alpha: 0.12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- THE CARD ENDS HERE ---
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        // Get Started Button
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

                        // NEW ELEMENT 1: Already have an account text link
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

                        // NEW ELEMENT 2: National Bank of Ethiopia Regulation Row
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
          ],
        ),
      ),
    );
  }
}

// UPDATE APPLIED: GlowOrb widget implementation now features custom blend shadows
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});
  @override
  build(BuildContext context) {
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

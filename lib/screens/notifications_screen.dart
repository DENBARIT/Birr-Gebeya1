import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_system.dart';
import '../models/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: BirrTheme.surface,
        elevation: 0,
        title: Text(
          'Alerts & Info',
          style: BirrTheme.getHeadlineLg(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (appState.notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                appState.clearAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                    backgroundColor: BirrTheme.onSurfaceVariant,
                  ),
                );
              },
              child: Text(
                'Clear All',
                style: BirrTheme.getLabelBold(
                  context,
                ).copyWith(color: BirrTheme.primary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Subtitle
                Text(
                  'Stay updated with your investment activities',
                  style: BirrTheme.getLabelMd(context),
                ),
                const SizedBox(height: 16),

                // Notification Feed
                if (appState.notifications.isEmpty)
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: BirrTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: BirrTheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All caught up!',
                          style: BirrTheme.getHeadlineMdMobile(context)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: BirrTheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have no new alerts or updates.',
                          style: BirrTheme.getLabelMd(context),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = appState.notifications[index];
                      final iconData = _getNotificationIcon(notif.title);
                      final iconColor = _getNotificationColor(notif.title);

                      return GestureDetector(
                        onTap: () {
                          appState.markNotificationAsRead(notif.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? BirrTheme.surfaceContainerLowest.withValues(
                                    alpha: 0.7,
                                  )
                                : BirrTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: notif.isRead
                                  ? BirrTheme.outlineVariant.withValues(
                                      alpha: 0.2,
                                    )
                                  : iconColor.withValues(alpha: 0.25),
                              width: notif.isRead ? 1.0 : 1.5,
                            ),
                            boxShadow: BirrTheme.softShadow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.title.toUpperCase(),
                                            style:
                                                BirrTheme.getLabelBold(
                                                  context,
                                                ).copyWith(
                                                  color: iconColor,
                                                  fontSize: 10,
                                                  letterSpacing: 0.5,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(notif.timestamp),
                                          style: BirrTheme.getLabelMd(
                                            context,
                                          ).copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.description,
                                      style: BirrTheme.getBodyMd(context)
                                          .copyWith(
                                            fontSize: 13.5,
                                            color: notif.isRead
                                                ? BirrTheme.onSurfaceVariant
                                                : BirrTheme.onSurface,
                                            fontWeight: notif.isRead
                                                ? FontWeight.normal
                                                : FontWeight.w500,
                                            height: 1.3,
                                          ),
                                    ),

                                    // Progress bar specifically for POOL ALERT notifications
                                    if (notif.title.contains('Pool') ||
                                        notif.title.contains('POOL'))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          child: const LinearProgressIndicator(
                                            value: 0.90,
                                            backgroundColor: Color(0xFFFDECE9),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  BirrTheme.secondary,
                                                ),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Aesthetic Background Illustration Section
                const SizedBox(height: 24),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BirrTheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBVIhP0K-1O6F3_lDdvhWVUdpggeBjpmA_eOBE6U1ZZ6gjyCI3I2x8j3gAhZB6_xh5BA4vOlnZ-qE4Wh3whgimIxxpcmA18-GS3qPH3zI3b3ojAliKMptQNnOwnWfmhDST4PcOXVZo9-Ftm2THCp7mm1dIEDzExPPKcve_HF77Hv9hKHMrGPwrYDfWw9Lx96NGGJGIo4FNPJsB0zdriqHXKE4xGk814hxYEk514IMEZYbtp6U0Z4aawNChLZZ7dcsLZHEzxakez6g',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black12,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      'Growth in Motion'.toUpperCase(),
                      style: BirrTheme.getLabelBold(context).copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    final t = title.toUpperCase();
    if (t.contains('CONFIRMED')) {
      return Icons.check_circle;
    }
    if (t.contains('ALERT') || t.contains('WARNING')) {
      return Icons.notifications_active;
    }
    if (t.contains('PAYOUT') ||
        t.contains('CREDITED') ||
        t.contains('RECEIVED')) {
      return Icons.payments;
    }
    if (t.contains('CONNECTED')) {
      return Icons.link;
    }
    return Icons.info;
  }

  Color _getNotificationColor(String title) {
    final t = title.toUpperCase();
    if (t.contains('CONFIRMED')) {
      return BirrTheme.primary;
    }
    if (t.contains('ALERT') || t.contains('WARNING')) {
      return BirrTheme.secondary;
    }
    if (t.contains('PAYOUT') ||
        t.contains('CREDITED') ||
        t.contains('RECEIVED')) {
      return const Color(0xFF78352B);
    }
    if (t.contains('CONNECTED')) {
      return BirrTheme.primaryContainer;
    }
    return BirrTheme.onSurfaceVariant;
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

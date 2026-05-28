import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_system.dart';
import '../models/app_state.dart';
import '../models/investment_pool.dart';
import 'invest_detail_screen.dart';
import 'dashboard_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Calculate actual earnings. We mock total earned to be roughly 6.2% of invested or derived from holdings expected yields
    double totalEarned = 0.0;
    for (var holding in appState.holdings) {
      totalEarned += (holding.expectedReturn - holding.investedAmount);
    }

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: BirrTheme.surface,
        elevation: 0,
        title: Text(
          'My Portfolio',
          style: BirrTheme.getHeadlineLg(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title Subtitle
                Text(
                  'Your current asset performance',
                  style: BirrTheme.getLabelMd(context),
                ),
                const SizedBox(height: 16),

                // Summary Bento Grid
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 120,
                        decoration: BoxDecoration(
                          color: BirrTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BirrTheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: BirrTheme.softShadow,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              top: -10,
                              child: Icon(
                                Icons.account_balance,
                                size: 56,
                                color: BirrTheme.primary.withValues(
                                  alpha: 0.06,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'TOTAL INVESTED',
                                  style: BirrTheme.getLabelBold(context)
                                      .copyWith(
                                        color: BirrTheme.onSurfaceVariant,
                                        fontSize: 10,
                                        letterSpacing: 0.8,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      appState.totalInvested.toStringAsFixed(0),
                                      style:
                                          BirrTheme.getDisplayCurrency(
                                            context,
                                          ).copyWith(
                                            color: BirrTheme.primary,
                                            fontSize: 28,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ETB',
                                      style: BirrTheme.getLabelBold(context)
                                          .copyWith(
                                            color: BirrTheme.primaryContainer,
                                          ),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 110,
                        decoration: BoxDecoration(
                          color: BirrTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BirrTheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: BirrTheme.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Earned',
                              style: BirrTheme.getLabelBold(
                                context,
                              ).copyWith(color: BirrTheme.onSurfaceVariant),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  totalEarned.toStringAsFixed(0),
                                  style: BirrTheme.getHeadlineMd(context)
                                      .copyWith(
                                        color: BirrTheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'ETB',
                                  style: BirrTheme.getLabelBold(context)
                                      .copyWith(
                                        color: BirrTheme.secondary,
                                        fontSize: 9,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: BirrTheme.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+6.2%',
                                  style: BirrTheme.getLabelBold(context)
                                      .copyWith(
                                        color: BirrTheme.primary,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        height: 110,
                        decoration: BoxDecoration(
                          color: BirrTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BirrTheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: BirrTheme.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Portfolio Health',
                              style: BirrTheme.getLabelBold(
                                context,
                              ).copyWith(color: BirrTheme.onSurfaceVariant),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.85,
                                backgroundColor: BirrTheme.surfaceContainer,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  BirrTheme.primary,
                                ),
                                minHeight: 5,
                              ),
                            ),
                            Text(
                              'Excellent',
                              style: BirrTheme.getLabelBold(context).copyWith(
                                color: BirrTheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Active holdings list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE ASSETS',
                      style: BirrTheme.getLabelBold(context).copyWith(
                        color: BirrTheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(
                      Icons.filter_list,
                      color: BirrTheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (appState.holdings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: BirrTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No active holdings. Go to Invest tab to make your first investment!',
                        style: BirrTheme.getBodyMd(
                          context,
                        ).copyWith(color: BirrTheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...appState.holdings.map((holding) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BirrTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(color: BirrTheme.primary, width: 4),
                        ),
                        boxShadow: BirrTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    holding.title,
                                    style: BirrTheme.getHeadlineMdMobile(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BirrTheme.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          'Active',
                                          style: BirrTheme.getLabelBold(context)
                                              .copyWith(
                                                color: BirrTheme.primary,
                                                fontSize: 9,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${holding.daysRemaining} days left',
                                        style: BirrTheme.getLabelMd(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.verified,
                                color: BirrTheme.primary,
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: BirrTheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRINCIPAL',
                                    style: BirrTheme.getLabelMd(context)
                                        .copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${holding.investedAmount.toStringAsFixed(0)} ETB',
                                    style: BirrTheme.getHeadlineMdMobile(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Look up parent pool
                                  final pool = appState.pools.firstWhere(
                                    (p) => p.id == holding.poolId,
                                    orElse: () => TBillPool(
                                      id: holding.poolId,
                                      title: holding.title,
                                      yieldRate: holding.yieldRate,
                                      progress: 0.8,
                                      minInvestment: 500,
                                      type: 'Fixed Term',
                                      termInDays: holding.termInDays,
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InvestDetailScreen(pool: pool),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chevron_right, size: 16),
                                label: const Text('Details'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: BirrTheme.primary,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 20),
                Text(
                  'ARCHIVED',
                  style: BirrTheme.getLabelBold(context).copyWith(
                    color: BirrTheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Archived matured card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BirrTheme.surfaceContainerLow.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '91-Day Treasury Bill',
                                style: BirrTheme.getHeadlineMdMobile(context)
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: BirrTheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BirrTheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Matured',
                                      style: BirrTheme.getLabelBold(context)
                                          .copyWith(
                                            color: BirrTheme.onSurfaceVariant,
                                            fontSize: 9,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '0.8% Share',
                                    style: BirrTheme.getLabelMd(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.history,
                            color: BirrTheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: BirrTheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SETTLED AMOUNT',
                                style: BirrTheme.getLabelMd(context).copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '4,000 ETB',
                                style: BirrTheme.getHeadlineMdMobile(context)
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: BirrTheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          Text(
                            'Mar 12, 2026',
                            style: BirrTheme.getLabelMd(
                              context,
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Explore markets section
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: BirrTheme.outlineVariant,
                      width: 2.0,
                      style: BorderStyle
                          .none, // Can represent dashed with border container in custom painter, but simple thin outline looks premium
                    ),
                    color: BirrTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.add_chart_outlined,
                        color: BirrTheme.primaryContainer,
                        size: 38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Looking to expand your earnings?',
                        style: BirrTheme.getBodyMd(
                          context,
                        ).copyWith(color: BirrTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Switch to InvestMarketScreen index (1)
                          final shellState = context
                              .findAncestorStateOfType<
                                AppNavigationShellState
                              >();
                          if (shellState != null) {
                            shellState.onItemTapped(1);
                          }
                        },
                        child: Text(
                          'EXPLORE MARKETS',
                          style: BirrTheme.getLabelBold(context).copyWith(
                            color: BirrTheme.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
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
}

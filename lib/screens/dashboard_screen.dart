import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/design_system.dart';
import '../models/app_state.dart';
import '../models/investment_pool.dart';
import 'chatbot_screen.dart';
import 'invest_detail_screen.dart';
import 'portfolio_screen.dart';
import 'notifications_screen.dart';
import 'splash_screen.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => AppNavigationShellState();
}

class AppNavigationShellState extends State<AppNavigationShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardScreen(),
      InvestMarketScreen(),
      PortfolioScreen(),
      NotificationsScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void onItemTapped(int index) => _onItemTapped(index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
        },
        backgroundColor: BirrTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Invest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: BirrTheme.surface,
        elevation: 0,
        title: Text(
          'ብር Gebeya',
          style: BirrTheme.getHeadlineLgMobile(
            context,
          ).copyWith(color: BirrTheme.primary, fontWeight: FontWeight.w800),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x33005440)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              child: Text(
                'English',
                style: BirrTheme.getLabelBold(
                  context,
                ).copyWith(color: BirrTheme.primary),
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.read<AppState>().refreshFromSupabase(),
            icon: const Icon(Icons.refresh),
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
                Text(
                  'Good morning,',
                  style: BirrTheme.getBodyMd(
                    context,
                  ).copyWith(color: BirrTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appState.userName} 👋',
                  style: BirrTheme.getHeadlineLg(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BirrTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: BirrTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Icon(
                          Icons.account_balance,
                          size: 70,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL INVESTED',
                            style: BirrTheme.getLabelBold(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ETB ${appState.totalInvested.toStringAsFixed(0)}',
                            style: BirrTheme.getDisplayCurrency(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expected Return',
                                      style: BirrTheme.getLabelMd(context)
                                          .copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ETB ${appState.expectedReturn.toStringAsFixed(0)}',
                                      style: BirrTheme.getHeadlineMd(context)
                                          .copyWith(
                                            color: const Color(0xFF9AEDCF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Maturity',
                                      style: BirrTheme.getLabelMd(context)
                                          .copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${appState.nextMaturityDays} Days',
                                      style: BirrTheme.getHeadlineMd(context)
                                          .copyWith(
                                            color: const Color(0xFF9AEDCF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Treasury bill pools',
                  style: BirrTheme.getHeadlineMd(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...appState.pools.map((pool) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BirrTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pool.title,
                                style: BirrTheme.getHeadlineMd(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${pool.yieldRate.toStringAsFixed(1)}%',
                              style: BirrTheme.getHeadlineMd(context).copyWith(
                                color: BirrTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${pool.termInDays} days • Min ETB ${pool.minInvestment.toStringAsFixed(0)}',
                          style: BirrTheme.getBodyMd(
                            context,
                          ).copyWith(color: BirrTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pool.progress,
                            minHeight: 8,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              BirrTheme.primary,
                            ),
                            backgroundColor: BirrTheme.surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvestDetailScreen(pool: pool),
                                ),
                              );
                            },
                            child: const Text('Invest'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  'Your holdings',
                  style: BirrTheme.getHeadlineMd(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (appState.holdings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BirrTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No holdings yet.',
                      style: BirrTheme.getBodyMd(
                        context,
                      ).copyWith(color: BirrTheme.onSurfaceVariant),
                    ),
                  )
                else
                  ...appState.holdings.map(
                    (h) => _HoldingCard(holding: h),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A distinct, informative card for a single holding — shows the pool it belongs
/// to, its own yield, invested amount, expected return and maturity progress.
class _HoldingCard extends StatelessWidget {
  final Holding holding;

  const _HoldingCard({required this.holding});

  @override
  Widget build(BuildContext context) {
    final elapsed = holding.termInDays - holding.daysRemaining;
    final progress = holding.termInDays == 0
        ? 0.0
        : (elapsed / holding.termInDays).clamp(0.0, 1.0);
    final isMatured = holding.daysRemaining <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BirrTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BirrTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + yield badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  holding.title,
                  style: BirrTheme.getHeadlineMd(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: BirrTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${holding.yieldRate.toStringAsFixed(1)}% p.a.',
                  style: BirrTheme.getLabelBold(
                    context,
                  ).copyWith(color: BirrTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Invested + expected return
          Row(
            children: [
              Expanded(
                child: _HoldingStat(
                  label: 'Invested',
                  value: 'ETB ${holding.investedAmount.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _HoldingStat(
                  label: 'Expected return',
                  value: 'ETB ${holding.expectedReturn.toStringAsFixed(0)}',
                  valueColor: BirrTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Maturity progress
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: BirrTheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                BirrTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMatured
                ? 'Matured • ${holding.termInDays}-day term complete'
                : '${holding.daysRemaining} of ${holding.termInDays} days remaining',
            style: BirrTheme.getLabelMd(
              context,
            ).copyWith(color: BirrTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HoldingStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _HoldingStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BirrTheme.getLabelMd(
            context,
          ).copyWith(color: BirrTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: BirrTheme.getBodyMd(context).copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? BirrTheme.onSurface,
          ),
        ),
      ],
    );
  }
}

enum InvestBondCategory { treasuryBills, commercialBonds, otherBonds }

enum InvestReleaseFilter { all, recent, expired }

enum InvestProfitFilter { all, highestFirst, lowestFirst }

enum InvestEntryFilter { all, lowestFirst, highestFirst }

class InvestMarketScreen extends StatefulWidget {
  const InvestMarketScreen({super.key});

  @override
  State<InvestMarketScreen> createState() => _InvestMarketScreenState();
}

class _InvestMarketScreenState extends State<InvestMarketScreen> {
  InvestBondCategory? _categoryFilter;
  InvestReleaseFilter _releaseFilter = InvestReleaseFilter.all;
  InvestProfitFilter _profitFilter = InvestProfitFilter.all;
  InvestEntryFilter _entryFilter = InvestEntryFilter.all;

  InvestBondCategory _categorizePool(TBillPool pool) {
    final searchableText = '${pool.id} ${pool.title} ${pool.type}'
        .toLowerCase();
    if (searchableText.contains('treasury') ||
        searchableText.contains('bill') ||
        searchableText.contains('tbill')) {
      return InvestBondCategory.treasuryBills;
    }
    if (searchableText.contains('commercial bond') ||
        searchableText.contains('commercial')) {
      return InvestBondCategory.commercialBonds;
    }
    return InvestBondCategory.otherBonds;
  }

  String _categoryLabel(InvestBondCategory category) {
    switch (category) {
      case InvestBondCategory.treasuryBills:
        return 'Treasury Bills';
      case InvestBondCategory.commercialBonds:
        return 'Commercial Bonds';
      case InvestBondCategory.otherBonds:
        return 'Other Bonds';
    }
  }

  String _releaseLabel(InvestReleaseFilter filter) {
    switch (filter) {
      case InvestReleaseFilter.all:
        return 'All release dates';
      case InvestReleaseFilter.recent:
        return 'Recent';
      case InvestReleaseFilter.expired:
        return 'Expired';
    }
  }

  String _profitLabel(InvestProfitFilter filter) {
    switch (filter) {
      case InvestProfitFilter.all:
        return 'Any profit';
      case InvestProfitFilter.highestFirst:
        return 'Highest profit first';
      case InvestProfitFilter.lowestFirst:
        return 'Lowest profit first';
    }
  }

  String _entryLabel(InvestEntryFilter filter) {
    switch (filter) {
      case InvestEntryFilter.all:
        return 'Any amount';
      case InvestEntryFilter.lowestFirst:
        return 'Lowest entry amount';
      case InvestEntryFilter.highestFirst:
        return 'Highest entry amount';
    }
  }

  bool _matchesRelease(TBillPool pool) {
    switch (_releaseFilter) {
      case InvestReleaseFilter.all:
        return true;
      case InvestReleaseFilter.recent:
        return pool.termInDays <= 91;
      case InvestReleaseFilter.expired:
        return pool.termInDays > 91;
    }
  }

  bool _matchesCategory(TBillPool pool) {
    var selectedCategory = _categoryFilter;
    if (selectedCategory == null) {
      return true;
    }
    return _categorizePool(pool) == selectedCategory;
  }

  int _comparePools(TBillPool a, TBillPool b) {
    if (_profitFilter != InvestProfitFilter.all) {
      final profitCompare = switch (_profitFilter) {
        InvestProfitFilter.highestFirst => b.yieldRate.compareTo(a.yieldRate),
        InvestProfitFilter.lowestFirst => a.yieldRate.compareTo(b.yieldRate),
        InvestProfitFilter.all => 0,
      };
      if (profitCompare != 0) {
        return profitCompare;
      }
    }

    if (_entryFilter != InvestEntryFilter.all) {
      final entryCompare = switch (_entryFilter) {
        InvestEntryFilter.lowestFirst => a.minInvestment.compareTo(
          b.minInvestment,
        ),
        InvestEntryFilter.highestFirst => b.minInvestment.compareTo(
          a.minInvestment,
        ),
        InvestEntryFilter.all => 0,
      };
      if (entryCompare != 0) {
        return entryCompare;
      }
    }

    return a.termInDays.compareTo(b.termInDays);
  }

  List<TBillPool> _filteredPools(List<TBillPool> pools) {
    final filtered = pools
        .where(_matchesCategory)
        .where(_matchesRelease)
        .toList();

    if (_profitFilter != InvestProfitFilter.all ||
        _entryFilter != InvestEntryFilter.all) {
      filtered.sort(_comparePools);
    }

    return filtered;
  }

  bool get _hasActiveFilters {
    return _categoryFilter != null ||
        _releaseFilter != InvestReleaseFilter.all ||
        _profitFilter != InvestProfitFilter.all ||
        _entryFilter != InvestEntryFilter.all;
  }

  int get _activeFilterCount {
    var count = 0;
    if (_categoryFilter != null) count++;
    if (_releaseFilter != InvestReleaseFilter.all) count++;
    if (_profitFilter != InvestProfitFilter.all) count++;
    if (_entryFilter != InvestEntryFilter.all) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _categoryFilter = null;
      _releaseFilter = InvestReleaseFilter.all;
      _profitFilter = InvestProfitFilter.all;
      _entryFilter = InvestEntryFilter.all;
    });
  }

  void _openFilterSheet() {
    var selectedCategory = _categoryFilter;
    var selectedRelease = _releaseFilter;
    var selectedProfit = _profitFilter;
    var selectedEntry = _entryFilter;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: BirrTheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: BirrTheme.softShadow,
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BirrTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Filters',
                            style: BirrTheme.getHeadlineMd(
                              context,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                selectedCategory = null;
                                selectedRelease = InvestReleaseFilter.all;
                                selectedProfit = InvestProfitFilter.all;
                                selectedEntry = InvestEntryFilter.all;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Bond type', style: BirrTheme.getLabelBold(context)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: selectedCategory == null,
                            onSelected: (_) {
                              setSheetState(() => selectedCategory = null);
                            },
                          ),
                          ...InvestBondCategory.values.map(
                            (category) => ChoiceChip(
                              label: Text(_categoryLabel(category)),
                              selected: selectedCategory == category,
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedCategory = category;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Release date',
                        style: BirrTheme.getLabelBold(context),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: InvestReleaseFilter.values.map((filter) {
                          return ChoiceChip(
                            label: Text(_releaseLabel(filter)),
                            selected: selectedRelease == filter,
                            onSelected: (_) {
                              setSheetState(() => selectedRelease = filter);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Profit amount',
                        style: BirrTheme.getLabelBold(context),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: InvestProfitFilter.values.map((filter) {
                          return ChoiceChip(
                            label: Text(_profitLabel(filter)),
                            selected: selectedProfit == filter,
                            onSelected: (_) {
                              setSheetState(() => selectedProfit = filter);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Additional filter',
                        style: BirrTheme.getLabelBold(context),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: InvestEntryFilter.values.map((filter) {
                          return ChoiceChip(
                            label: Text(_entryLabel(filter)),
                            selected: selectedEntry == filter,
                            onSelected: (_) {
                              setSheetState(() => selectedEntry = filter);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _categoryFilter = selectedCategory;
                              _releaseFilter = selectedRelease;
                              _profitFilter = selectedProfit;
                              _entryFilter = selectedEntry;
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BirrTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Apply filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onClear) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onClear,
      backgroundColor: BirrTheme.surfaceContainerLow,
      side: BorderSide(color: BirrTheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filteredPools = _filteredPools(appState.pools);

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: BirrTheme.surface,
        elevation: 0,
        title: Text(
          'Investment Markets',
          style: BirrTheme.getHeadlineLg(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _openFilterSheet,
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filters',
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: BirrTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_hasActiveFilters)
            IconButton(
              onPressed: _resetFilters,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available Investment Bonds',
                      style: BirrTheme.getHeadlineMdMobile(
                        context,
                      ).copyWith(color: BirrTheme.onSurfaceVariant),
                    ),
                  ),
                  Text(
                    '${filteredPools.length} found',
                    style: BirrTheme.getLabelBold(
                      context,
                    ).copyWith(color: BirrTheme.primary),
                  ),
                ],
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_categoryFilter != null)
                      _buildActiveFilterChip(
                        _categoryLabel(_categoryFilter!),
                        () => setState(() => _categoryFilter = null),
                      ),
                    if (_releaseFilter != InvestReleaseFilter.all)
                      _buildActiveFilterChip(
                        _releaseLabel(_releaseFilter),
                        () => setState(
                          () => _releaseFilter = InvestReleaseFilter.all,
                        ),
                      ),
                    if (_profitFilter != InvestProfitFilter.all)
                      _buildActiveFilterChip(
                        _profitLabel(_profitFilter),
                        () => setState(
                          () => _profitFilter = InvestProfitFilter.all,
                        ),
                      ),
                    if (_entryFilter != InvestEntryFilter.all)
                      _buildActiveFilterChip(
                        _entryLabel(_entryFilter),
                        () => setState(
                          () => _entryFilter = InvestEntryFilter.all,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: filteredPools.isEmpty
                    ? Center(
                        child: Text(
                          'No bonds match the selected filters.',
                          style: BirrTheme.getBodyMd(
                            context,
                          ).copyWith(color: BirrTheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPools.length,
                        itemBuilder: (context, index) {
                          final pool = filteredPools[index];
                          final category = _categorizePool(pool);
                          final isTreasury =
                              category == InvestBondCategory.treasuryBills;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: BirrTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: BirrTheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              boxShadow: BirrTheme.softShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isTreasury
                                            ? const Color(
                                                0xFFFDD8B1,
                                              ).withValues(alpha: 0.4)
                                            : BirrTheme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _categoryLabel(category).toUpperCase(),
                                        style: BirrTheme.getLabelBold(context)
                                            .copyWith(
                                              fontSize: 9,
                                              color: isTreasury
                                                  ? BirrTheme.secondary
                                                  : BirrTheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${pool.yieldRate}% Yield p.a.',
                                      style: BirrTheme.getLabelBold(
                                        context,
                                      ).copyWith(color: BirrTheme.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  pool.title,
                                  style: BirrTheme.getHeadlineMd(
                                    context,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Backed by the Federal Government of Ethiopia. Term: ${pool.termInDays} Days.',
                                  style: BirrTheme.getBodyMd(
                                    context,
                                  ).copyWith(color: BirrTheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Min Investment',
                                          style: BirrTheme.getLabelMd(context),
                                        ),
                                        Text(
                                          'ETB ${pool.minInvestment.toStringAsFixed(0)}',
                                          style: BirrTheme.getLabelBold(
                                            context,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InvestDetailScreen(pool: pool),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: BirrTheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Details & Buy',
                                        style: BirrTheme.getLabelBold(
                                          context,
                                        ).copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut(BuildContext context) async {
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _saveAvatarPreference({
    required String avatarType,
    required String avatarValue,
  }) async {
    final appState = context.read<AppState>();
    await appState.updateProfile(
      userName: appState.userName,
      fullNameValue: appState.fullName ?? appState.userName,
      telebirrNumberValue: appState.telebirrNumber,
      nationalIdValue: appState.nationalId,
      dateOfBirthValue: appState.dateOfBirth,
      genderValue: appState.gender,
      regionValue: appState.region,
      avatarTypeValue: avatarType,
      avatarValueValue: avatarValue,
      email: appState.profile?.email,
      phoneNumber: appState.profile?.phoneNumber,
    );

    await appState.refreshFromSupabase();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickDeviceAvatar() async {
    // Image picking not available in this build configuration.
    // To enable, add image_picker to pubspec.yaml dependencies.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image picking not enabled in this build.'),
        ),
      );
    }
  }

  Future<void> _chooseAvatar() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: BirrTheme.surface,
      builder: (sheetContext) {
        const avatarKeys = [
          'avatar_1',
          'avatar_2',
          'avatar_3',
          'avatar_4',
          'avatar_5',
          'avatar_6',
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose profile photo',
                  style: BirrTheme.getHeadlineMd(
                    sheetContext,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Pick from device'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickDeviceAvatar();
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Built-in avatars',
                  style: BirrTheme.getLabelBold(
                    sheetContext,
                  ).copyWith(color: BirrTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: avatarKeys.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final avatarKey = avatarKeys[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _saveAvatarPreference(
                          avatarType: 'builtin',
                          avatarValue: avatarKey,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: BirrTheme.surfaceContainerLow,
                          border: Border.all(color: BirrTheme.outlineVariant),
                        ),
                        child: Center(
                          child: _buildBuiltInAvatar(avatarKey, size: 56),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuiltInAvatar(String avatarKey, {double size = 72}) {
    final color = _avatarColorForKey(avatarKey);
    final icon = _avatarIconForKey(avatarKey);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: size * 0.42),
    );
  }

  Color _avatarColorForKey(String avatarKey) {
    switch (avatarKey) {
      case 'avatar_1':
        return const Color(0xFF005440);
      case 'avatar_2':
        return const Color(0xFF0E7490);
      case 'avatar_3':
        return const Color(0xFF7C4A00);
      case 'avatar_4':
        return const Color(0xFF4A5568);
      case 'avatar_5':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF0F6E56);
    }
  }

  IconData _avatarIconForKey(String avatarKey) {
    switch (avatarKey) {
      case 'avatar_1':
        return Icons.person;
      case 'avatar_2':
        return Icons.work_outline;
      case 'avatar_3':
        return Icons.account_balance_wallet_outlined;
      case 'avatar_4':
        return Icons.verified_user_outlined;
      case 'avatar_5':
        return Icons.spa_outlined;
      default:
        return Icons.shield_outlined;
    }
  }

  Widget _buildProfileAvatar(AppState appState) {
    final avatarType = appState.avatarType;
    final avatarValue = appState.avatarValue;

    Widget child;
    if (avatarType == 'device' &&
        avatarValue != null &&
        avatarValue.isNotEmpty &&
        File(avatarValue).existsSync()) {
      child = ClipOval(
        child: Image.file(
          File(avatarValue),
          fit: BoxFit.cover,
          width: 104,
          height: 104,
        ),
      );
    } else if (avatarType == 'builtin' &&
        avatarValue != null &&
        avatarValue.isNotEmpty) {
      child = _buildBuiltInAvatar(avatarValue, size: 104);
    } else {
      final name = (appState.fullName ?? appState.userName).trim();
      final initials = name.isEmpty
          ? 'BG'
          : name
                .split(RegExp(r'\s+'))
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part.substring(0, 1).toUpperCase())
                .join();

      child = CircleAvatar(
        radius: 52,
        backgroundColor: BirrTheme.primaryContainer,
        child: Text(
          initials,
          style: BirrTheme.getHeadlineMd(
            context,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: BirrTheme.primary, width: 2),
          ),
          child: child,
        ),
        GestureDetector(
          onTap: _chooseAvatar,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: BirrTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Not provided';
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: BirrTheme.surface,
        elevation: 0,
        title: Text(
          'Profile Settings',
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
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      _buildProfileAvatar(appState),
                      const SizedBox(height: 16),
                      Text(
                        appState.fullName ?? appState.userName,
                        style: BirrTheme.getHeadlineLg(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appState.isTelebirrConnected
                            ? 'Telebirr Connected'
                            : 'Telebirr not linked',
                        style: BirrTheme.getLabelMd(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: BirrTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        context,
                        icon: Icons.phone_android,
                        title: 'Telebirr Status',
                        value: appState.isTelebirrConnected
                            ? 'Connected'
                            : 'Not linked',
                        valueColor: appState.isTelebirrConnected
                            ? BirrTheme.primary
                            : BirrTheme.error,
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildProfileItem(
                        context,
                        icon: Icons.verified_user_outlined,
                        title: 'KYC Status',
                        value: appState.hasKycProfile
                            ? 'Verified'
                            : 'Pending profile completion',
                        valueColor: appState.hasKycProfile
                            ? BirrTheme.primary
                            : BirrTheme.secondary,
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildProfileItem(
                        context,
                        icon: Icons.badge_outlined,
                        title: 'Full Name',
                        value: appState.fullName ?? appState.userName,
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildProfileItem(
                        context,
                        icon: Icons.credit_card_outlined,
                        title: 'National ID',
                        value: appState.nationalId ?? 'Not provided',
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildProfileItem(
                        context,
                        icon: Icons.cake_outlined,
                        title: 'Date of Birth',
                        value: _formatDate(appState.dateOfBirth),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildProfileItem(
                        context,
                        icon: Icons.location_on_outlined,
                        title: 'Region',
                        value: appState.region ?? 'Not provided',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: BirrTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        context,
                        icon: Icons.mail_outline,
                        title: 'Email',
                        value: appState.profile?.email ?? 'Not provided',
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildProfileItem(
                        context,
                        icon: Icons.phone_iphone,
                        title: 'Phone Number',
                        value: appState.profile?.phoneNumber ?? 'Not provided',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => _signOut(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BirrTheme.error,
                      side: const BorderSide(color: BirrTheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Logout / Reset App',
                      style: BirrTheme.getLabelBold(
                        context,
                      ).copyWith(color: BirrTheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: BirrTheme.primaryContainer, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BirrTheme.getLabelMd(context)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: BirrTheme.getBodyMd(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? BirrTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_system.dart';
import '../models/app_state.dart';
import '../models/investment_pool.dart';
import 'admin_session.dart';

// ---------- Mock user directory (KAN-26) ----------
// Swap this for a real Supabase users table query when you have one.
class AdminMockUser {
  final String id;
  final String name;
  final String phone;
  String kycStatus; // pending | verified | rejected | suspended
  AdminMockUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.kycStatus,
  });
}

final List<AdminMockUser> _mockUsers = [
  AdminMockUser(
    id: 'u1',
    name: 'Selam Tesfaye',
    phone: '+251 911 223344',
    kycStatus: 'pending',
  ),
  AdminMockUser(
    id: 'u2',
    name: 'Abebe Kebede',
    phone: '+251 922 334455',
    kycStatus: 'verified',
  ),
  AdminMockUser(
    id: 'u3',
    name: 'Marta Alemu',
    phone: '+251 933 445566',
    kycStatus: 'pending',
  ),
  AdminMockUser(
    id: 'u4',
    name: 'Yonas Bekele',
    phone: '+251 944 556677',
    kycStatus: 'suspended',
  ),
];

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _allTabs = [
    Tab(text: 'Overview'),
    Tab(text: 'Users'),
    Tab(text: 'T-Bills'),
    Tab(text: 'Investments'),
    Tab(text: 'Analytics'),
    Tab(text: 'Roles'),
  ];

  List<int> get _visibleTabIndexes {
    final role = AdminSession.instance.current?.role ?? AdminRole.support;
    final indexes = <int>[
      0,
      1,
      3,
      4,
    ]; // Overview, Users, Investments, Analytics
    if (role != AdminRole.support) {
      indexes.add(2); // T-Bills — hidden from support
    }
    if (role == AdminRole.superAdmin) {
      indexes.add(5); // Roles — superAdmin only
    }
    indexes.sort();
    return indexes;
  }

  late List<int> _visible;

  @override
  void initState() {
    super.initState();
    _visible = _visibleTabIndexes;
    _tabController = TabController(length: _visible.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _visible.map((i) => _allTabs[i]).toList();
    final views = _visible.map<Widget>((i) {
      switch (i) {
        case 0:
          return const _OverviewTab();
        case 1:
          return const _UsersTab();
        case 2:
          return const _TBillsTab();
        case 3:
          return const _InvestmentsTab();
        case 4:
          return const _AnalyticsTab();
        case 5:
          return const _RolesTab();
        default:
          return const SizedBox.shrink();
      }
    }).toList();

    final admin = AdminSession.instance.current;

    return Scaffold(
      backgroundColor: BirrTheme.background,
      appBar: AppBar(
        backgroundColor: BirrTheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Admin Console${admin != null ? ' · ${admin.name}' : ''}',
          style: BirrTheme.getHeadlineMdMobile(
            context,
          ).copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: tabs,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out of Admin',
            onPressed: () {
              AdminSession.instance.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: TabBarView(controller: _tabController, children: views),
    );
  }
}

// ---------- Overview (KAN-24) ----------
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pendingKyc = _mockUsers.where((u) => u.kycStatus == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Overview',
            style: BirrTheme.getHeadlineMd(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Live figures from the current session. Wire this to your users table for platform-wide totals.',
            style: BirrTheme.getBodyMd(
              context,
            ).copyWith(color: BirrTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: 'Active Pools',
                value: '${appState.pools.length}',
                icon: Icons.account_balance,
              ),
              _MetricCard(
                label: 'Total Invested',
                value: 'ETB ${appState.totalInvested.toStringAsFixed(0)}',
                icon: Icons.trending_up,
              ),
              _MetricCard(
                label: 'Active Holdings',
                value: '${appState.holdings.length}',
                icon: Icons.pie_chart,
              ),
              _MetricCard(
                label: 'Pending KYC',
                value: '$pendingKyc',
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (pendingKyc > 0)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BirrTheme.secondaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(BirrTheme.radiusMedium),
                border: Border.all(color: BirrTheme.secondaryContainer),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: BirrTheme.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$pendingKyc users are waiting on KYC approval.',
                      style: BirrTheme.getBodyMd(context),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BirrTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(BirrTheme.radiusMedium),
        border: Border.all(
          color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: BirrTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BirrTheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: BirrTheme.getHeadlineMd(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: BirrTheme.getLabelMd(
              context,
            ).copyWith(color: BirrTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------- Users (KAN-26) ----------
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String _query = '';
  String _statusFilter = 'all';

  List<AdminMockUser> get _filtered {
    return _mockUsers.where((u) {
      final matchesQuery =
          _query.isEmpty ||
          u.name.toLowerCase().contains(_query.toLowerCase()) ||
          u.phone.contains(_query);
      final matchesStatus =
          _statusFilter == 'all' || u.kycStatus == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _updateStatus(AdminMockUser user, String status) {
    setState(() => user.kycStatus = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user.name} marked as $status. Wire this to your users table to persist.',
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return BirrTheme.primary;
      case 'rejected':
      case 'suspended':
        return BirrTheme.error;
      default:
        return BirrTheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name or phone…',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: ['all', 'pending', 'verified', 'rejected', 'suspended']
                .map((s) {
                  return ChoiceChip(
                    label: Text(
                      s == 'all' ? 'All' : s[0].toUpperCase() + s.substring(1),
                    ),
                    selected: _statusFilter == s,
                    onSelected: (_) => setState(() => _statusFilter = s),
                  );
                })
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final u = _filtered[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BirrTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(BirrTheme.radiusMedium),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                style: BirrTheme.getBodyLg(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                u.phone,
                                style: BirrTheme.getLabelMd(context),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              u.kycStatus,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            u.kycStatus.toUpperCase(),
                            style: BirrTheme.getLabelBold(
                              context,
                            ).copyWith(color: _statusColor(u.kycStatus)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => _updateStatus(u, 'verified'),
                          child: const Text('Approve KYC'),
                        ),
                        OutlinedButton(
                          onPressed: () => _updateStatus(u, 'rejected'),
                          child: const Text('Reject'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: BirrTheme.error,
                          ),
                          onPressed: () => _updateStatus(u, 'suspended'),
                          child: const Text('Suspend'),
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
    );
  }
}

// ---------- T-Bills (KAN-27) ----------
class _TBillsTab extends StatelessWidget {
  const _TBillsTab();

  void _showPoolDialog(BuildContext context, {TBillPool? existing}) {
    final appState = context.read<AppState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final yieldController = TextEditingController(
      text: existing?.yieldRate.toString() ?? '',
    );
    final termController = TextEditingController(
      text: existing?.termInDays.toString() ?? '',
    );
    final minController = TextEditingController(
      text: existing?.minInvestment.toString() ?? '',
    );
    String type = existing?.type ?? 'Fixed Term';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null ? 'New T-Bill Listing' : 'Edit Listing',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: yieldController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Yield rate (%)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: termController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Term (days)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min investment (ETB)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Fixed Term',
                          child: Text('Fixed Term'),
                        ),
                        DropdownMenuItem(
                          value: 'Daily Liquidity',
                          child: Text('Daily Liquidity'),
                        ),
                      ],
                      onChanged: (v) => setDialogState(() => type = v ?? type),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final yieldRate =
                        double.tryParse(yieldController.text) ?? 0;
                    final term = int.tryParse(termController.text) ?? 0;
                    final minInv = double.tryParse(minController.text) ?? 0;
                    if (title.isEmpty ||
                        yieldRate <= 0 ||
                        term <= 0 ||
                        minInv <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill in all fields with valid values.',
                          ),
                        ),
                      );
                      return;
                    }
                    if (existing == null) {
                      appState.addPool(
                        TBillPool(
                          id: 'pool_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          yieldRate: yieldRate,
                          progress: 0.0,
                          minInvestment: minInv,
                          type: type,
                          termInDays: term,
                        ),
                      );
                    } else {
                      appState.updatePool(
                        existing.id,
                        title: title,
                        yieldRate: yieldRate,
                        termInDays: term,
                        minInvestment: minInv,
                        type: type,
                      );
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: Text(existing == null ? 'Publish' : 'Save changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPoolDialog(context),
        backgroundColor: BirrTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: appState.pools.length,
        itemBuilder: (context, index) {
          final pool = appState.pools[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BirrTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(BirrTheme.radiusMedium),
              border: Border.all(
                color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pool.title,
                        style: BirrTheme.getBodyLg(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${pool.yieldRate}% · ${pool.termInDays} days · ${pool.type}',
                        style: BirrTheme.getLabelMd(context),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showPoolDialog(context, existing: pool),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.archive_outlined,
                    color: BirrTheme.error,
                  ),
                  onPressed: () => appState.archivePool(pool.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------- Investments (KAN-28) ----------
class _InvestmentsTab extends StatelessWidget {
  const _InvestmentsTab();

  String _buildCsv(AppState appState) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Holding ID,Pool,Invested (ETB),Expected Return (ETB),Yield %,Purchase Date,Term (days),Days Remaining',
    );
    for (final h in appState.holdings) {
      buffer.writeln(
        '${h.id},${h.title},${h.investedAmount},${h.expectedReturn},${h.yieldRate},${h.purchaseDate.toIso8601String()},${h.termInDays},${h.daysRemaining}',
      );
    }
    return buffer.toString();
  }

  void _showExportDialog(BuildContext context, String csv) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export CSV'),
        content: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV copied to clipboard.')),
              );
            },
            child: const Text('Copy to clipboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final transactions = appState.notifications
        .where(
          (n) =>
              n.title == 'Investment Confirmed' ||
              n.title == 'Withdrawal Successful',
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportDialog(context, _buildCsv(appState)),
        backgroundColor: BirrTheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.download_outlined),
        label: const Text('Export CSV'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: BirrTheme.primary,
              unselectedLabelColor: BirrTheme.onSurfaceVariant,
              indicatorColor: BirrTheme.primary,
              tabs: [
                Tab(text: 'Investments'),
                Tab(text: 'Transaction History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  appState.holdings.isEmpty
                      ? Center(
                          child: Text(
                            'No active investments.',
                            style: BirrTheme.getBodyMd(context),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: appState.holdings.length,
                          itemBuilder: (context, index) {
                            final h = appState.holdings[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: BirrTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(
                                  BirrTheme.radiusMedium,
                                ),
                                border: Border.all(
                                  color: BirrTheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h.title,
                                          style: BirrTheme.getBodyLg(context)
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          'ETB ${h.investedAmount.toStringAsFixed(0)} · ${h.yieldRate}% p.a.',
                                          style: BirrTheme.getLabelMd(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${h.daysRemaining}d left',
                                    style: BirrTheme.getLabelBold(
                                      context,
                                    ).copyWith(color: BirrTheme.primary),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  transactions.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions yet.',
                            style: BirrTheme.getBodyMd(context),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            final isDeposit = t.title == 'Investment Confirmed';
                            return ListTile(
                              leading: Icon(
                                isDeposit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isDeposit
                                    ? BirrTheme.primary
                                    : BirrTheme.error,
                              ),
                              title: Text(
                                t.title,
                                style: BirrTheme.getBodyMd(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                t.description,
                                style: BirrTheme.getLabelMd(context),
                              ),
                            );
                          },
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

// ---------- Analytics (KAN-30) ----------
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final maxYield = appState.pools.isEmpty
        ? 1.0
        : appState.pools
              .map((p) => p.yieldRate)
              .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yield by pool',
            style: BirrTheme.getHeadlineMd(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: appState.pools.map((pool) {
                final heightFraction = maxYield == 0
                    ? 0.0
                    : pool.yieldRate / maxYield;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${pool.yieldRate}%',
                          style: BirrTheme.getLabelMd(context),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 130 * heightFraction,
                          decoration: BoxDecoration(
                            color: BirrTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pool.title.split(' ').first,
                          style: BirrTheme.getLabelMd(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Funding progress',
            style: BirrTheme.getHeadlineMd(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...appState.pools.map(
            (pool) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pool.title, style: BirrTheme.getBodyMd(context)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pool.progress,
                      minHeight: 10,
                      backgroundColor: BirrTheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        BirrTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Roles (KAN-29) ----------
class _RolesTab extends StatefulWidget {
  const _RolesTab();

  @override
  State<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<_RolesTab> {
  List<Map<String, dynamic>>? _accounts;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('admin_accounts').select();
      setState(() {
        _accounts = List<Map<String, dynamic>>.from(response as List);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error =
            'Could not load admin_accounts. Make sure the table exists in Supabase.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role permissions',
            style: BirrTheme.getHeadlineMd(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _RolePermissionRow(
            role: 'Super Admin',
            permissions:
                'Full access — users, T-Bills, investments, analytics, roles',
          ),
          const _RolePermissionRow(
            role: 'Analyst',
            permissions: 'Users, T-Bills, investments, analytics',
          ),
          const _RolePermissionRow(
            role: 'Support',
            permissions: 'Users, investments, analytics',
          ),
          const SizedBox(height: 24),
          Text(
            'Admin accounts',
            style: BirrTheme.getHeadlineMd(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Managed externally in the Supabase admin_accounts table.',
            style: BirrTheme.getLabelMd(
              context,
            ).copyWith(color: BirrTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(
              _error!,
              style: BirrTheme.getBodyMd(
                context,
              ).copyWith(color: BirrTheme.error),
            )
          else
            ...(_accounts ?? []).map(
              (a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(a['name']?.toString() ?? '—'),
                subtitle: Text('${a['email']} · ${a['role']}'),
                trailing: Icon(
                  a['is_active'] == false
                      ? Icons.block
                      : Icons.check_circle_outline,
                  color: a['is_active'] == false
                      ? BirrTheme.error
                      : BirrTheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RolePermissionRow extends StatelessWidget {
  final String role;
  final String permissions;
  const _RolePermissionRow({required this.role, required this.permissions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BirrTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(BirrTheme.radiusMedium),
        border: Border.all(
          color: BirrTheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: BirrTheme.getBodyLg(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(permissions, style: BirrTheme.getLabelMd(context)),
        ],
      ),
    );
  }
}

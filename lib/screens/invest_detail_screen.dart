import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_system.dart';
import '../models/app_state.dart';
import '../models/investment_pool.dart';
import 'dashboard_screen.dart';

class InvestDetailScreen extends StatefulWidget {
  final TBillPool pool;

  const InvestDetailScreen({super.key, required this.pool});

  @override
  State<InvestDetailScreen> createState() => _InvestDetailScreenState();
}

class _InvestDetailScreenState extends State<InvestDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double _enteredAmount = 0.0;
  double _calculatedYield = 0.0;
  double _calculatedReturn = 0.0;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.pool.minInvestment.toStringAsFixed(0);
    _updateCalculations(widget.pool.minInvestment);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    _updateCalculations(amt);
  }

  void _updateCalculations(double amount) {
    if (amount <= 0) {
      setState(() {
        _enteredAmount = 0.0;
        _calculatedYield = 0.0;
        _calculatedReturn = 0.0;
      });
      return;
    }

    // Expected Yield = Amount * (YieldRate / 100) * (Term / 365)
    final yieldVal =
        amount * (widget.pool.yieldRate / 100) * (widget.pool.termInDays / 365);
    setState(() {
      _enteredAmount = amount;
      _calculatedYield = double.parse(yieldVal.toStringAsFixed(2));
      _calculatedReturn = double.parse((amount + yieldVal).toStringAsFixed(2));
    });
  }

  void _confirmInvestment() {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog (mock bottom sheet drawer)
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: BirrTheme.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: BirrTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm Investment',
                  style: BirrTheme.getHeadlineLg(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review the details of your treasury bill subscription before proceeding.',
                  style: BirrTheme.getBodyMd(
                    context,
                  ).copyWith(color: BirrTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BirrTheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildConfirmRow(
                        'Investment Amount',
                        'ETB ${_enteredAmount.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 12),
                      _buildConfirmRow(
                        'Expected Yield (${widget.pool.yieldRate}%)',
                        '+ ETB ${_calculatedYield.toStringAsFixed(2)}',
                        valueColor: BirrTheme.primary,
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
                          Text(
                            'Total Return',
                            style: BirrTheme.getLabelBold(context),
                          ),
                          Text(
                            'ETB ${_calculatedReturn.toStringAsFixed(0)}',
                            style: BirrTheme.getHeadlineMd(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: BirrTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BirrTheme.secondary,
                          side: const BorderSide(color: BirrTheme.secondary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Perform transaction
                          final appState = Provider.of<AppState>(
                            context,
                            listen: false,
                          );
                          final success = appState.addInvestment(
                            widget.pool,
                            _enteredAmount,
                          );

                          Navigator.pop(context); // Close bottom sheet

                          if (success) {
                            setState(() {
                              _showSuccess = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BirrTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildConfirmRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: BirrTheme.getBodyMd(
            context,
          ).copyWith(color: BirrTheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: BirrTheme.getLabelBold(
            context,
          ).copyWith(color: valueColor ?? BirrTheme.onSurface),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessScreen(context);
    }

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
          'Investment Detail',
          style: BirrTheme.getHeadlineMdMobile(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: BirrTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // T-Bill Primary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BirrTheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      boxShadow: BirrTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFDD8B1,
                                      ).withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Government Bond',
                                      style: BirrTheme.getLabelBold(context)
                                          .copyWith(
                                            color: BirrTheme.secondary,
                                            fontSize: 9,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.pool.title,
                                    style: BirrTheme.getHeadlineLgMobile(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.pool.yieldRate}% p.a.',
                                  style: BirrTheme.getHeadlineMd(context)
                                      .copyWith(
                                        color: BirrTheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Annualized Yield',
                                  style: BirrTheme.getLabelMd(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: BirrTheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pool Progress',
                                  style: BirrTheme.getLabelMd(context),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    text:
                                        'ETB ${(500000 * widget.pool.progress).toStringAsFixed(0)} ',
                                    style:
                                        BirrTheme.getHeadlineMdMobile(
                                          context,
                                        ).copyWith(
                                          color: BirrTheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    children: [
                                      TextSpan(
                                        text: '/ 500,000',
                                        style: BirrTheme.getBodyMd(context)
                                            .copyWith(
                                              color: BirrTheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(widget.pool.progress * 100).toStringAsFixed(0)}%',
                              style: BirrTheme.getLabelBold(
                                context,
                              ).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.pool.progress,
                            backgroundColor: BirrTheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              BirrTheme.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              Icons.group_outlined,
                              color: BirrTheme.onSurfaceVariant,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '47 investors participating in this pool',
                              style: BirrTheme.getLabelMd(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Grid (Bento Style)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BirrTheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: BirrTheme.primary,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Duration',
                                style: BirrTheme.getLabelMd(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.pool.termInDays} Days',
                                style: BirrTheme.getHeadlineMdMobile(
                                  context,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BirrTheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: BirrTheme.primary,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Risk Level',
                                style: BirrTheme.getLabelMd(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Very Low',
                                style: BirrTheme.getHeadlineMdMobile(
                                  context,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Checkout Amount Input Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enter Amount',
                        style: BirrTheme.getHeadlineMd(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Wallet balance: ',
                        style: BirrTheme.getLabelMd(context),
                      ),
                      Text('ETB 8,200', style: BirrTheme.getLabelBold(context)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: BirrTheme.getDisplayCurrency(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount to invest';
                      }
                      final amt = double.tryParse(value);
                      if (amt == null || amt < widget.pool.minInvestment) {
                        return 'Minimum investment is ETB ${widget.pool.minInvestment.toStringAsFixed(0)}';
                      }
                      if (amt > 8200) {
                        return 'Insufficient wallet balance (Max: ETB 8,200)';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                        child: Text(
                          'ETB',
                          style: BirrTheme.getDisplayCurrency(context).copyWith(
                            color: BirrTheme.onSurfaceVariant,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Min: ETB ${widget.pool.minInvestment.toStringAsFixed(0)}',
                        style: BirrTheme.getLabelMd(context),
                      ),
                      Text(
                        'Max: ETB 50,000',
                        style: BirrTheme.getLabelMd(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Invest Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _confirmInvestment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BirrTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Invest Now',
                            style: BirrTheme.getHeadlineMdMobile(context)
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: BirrTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: BirrTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: BirrTheme.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Success!',
                style: BirrTheme.getHeadlineLg(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your investment in ${widget.pool.title} has been processed successfully.',
                style: BirrTheme.getBodyMd(
                  context,
                ).copyWith(color: BirrTheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to Dashboard index 0
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppNavigationShell(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BirrTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: BirrTheme.getHeadlineMdMobile(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

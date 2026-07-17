enum BondCategory { treasuryBills, commercialBonds, otherBonds }

/// Shared classifier so pools and holdings bucket into the same categories.
BondCategory categorizeBondText(String searchableText) {
  final text = searchableText.toLowerCase();
  if (text.contains('treasury') ||
      text.contains('bill') ||
      text.contains('tbill')) {
    return BondCategory.treasuryBills;
  }
  if (text.contains('commercial')) {
    return BondCategory.commercialBonds;
  }
  return BondCategory.otherBonds;
}

class TBillPool {
  final String id;
  final String title;
  final double yieldRate; // Yield rate percentage (e.g., 8.5 for 8.5%)
  final double progress; // Progress percentage (e.g., 0.73 for 73%)
  final double minInvestment;
  final String type; // "Fixed Term" or "Daily Liquidity"
  final int termInDays;

  TBillPool({
    required this.id,
    required this.title,
    required this.yieldRate,
    required this.progress,
    required this.minInvestment,
    required this.type,
    required this.termInDays,
  });

  /// Inferred from [id]/[title]/[type] text — keeps the invest-market
  /// filters and the investment detail badge classifying pools the same way.
  BondCategory get category => categorizeBondText('$id $title $type');

  /// Singular label for a single pool (e.g. the investment detail badge).
  String get categoryBadgeLabel {
    switch (category) {
      case BondCategory.treasuryBills:
        return 'Treasury Bill';
      case BondCategory.commercialBonds:
        return 'Commercial Bond';
      case BondCategory.otherBonds:
        return 'Other Bond';
    }
  }
}

class Holding {
  final String id;
  final String poolId;
  final String title;
  final double investedAmount;
  final double expectedReturn;
  final double yieldRate;
  final DateTime purchaseDate;
  final int termInDays;

  Holding({
    required this.id,
    required this.poolId,
    required this.title,
    required this.investedAmount,
    required this.expectedReturn,
    required this.yieldRate,
    required this.purchaseDate,
    required this.termInDays,
  });

  int get daysRemaining {
    final difference = purchaseDate
        .add(Duration(days: termInDays))
        .difference(DateTime.now())
        .inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Same classifier as [TBillPool.category], applied to a holding's own
  /// [poolId]/[title] text.
  BondCategory get category => categorizeBondText('$poolId $title');
}

class WithdrawalRecord {
  final String id;
  final double amount;
  final DateTime timestamp;

  WithdrawalRecord({
    required this.id,
    required this.amount,
    required this.timestamp,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });
}

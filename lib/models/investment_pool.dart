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
    final difference = purchaseDate.add(Duration(days: termInDays)).difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }
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

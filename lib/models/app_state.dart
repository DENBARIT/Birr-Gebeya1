import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'investment_pool.dart';
import '../localization/app_translations.dart';
import '../services/supabase_app_repository.dart';

class UserProfile {
  final String? email;
  final String? phoneNumber;

  UserProfile({this.email, this.phoneNumber});
}

class AppState extends ChangeNotifier {
  AppState() {
    _loadLanguage();
  }

  static const _languagePrefsKey = 'app_language';

  AppLanguage language = AppLanguage.english;

  /// Looks up a translated string for the current [language].
  String t(String key) => tr(language, key);

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      language = AppLanguageMeta.fromStorageCode(
        prefs.getString(_languagePrefsKey),
      );
      notifyListeners();
    } catch (_) {
      // Keep the English default if local storage isn't available.
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    language = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languagePrefsKey, lang.storageCode);
    } catch (_) {
      // Non-fatal: the in-memory selection still applies this session.
    }
  }

  String userName = "";
  String? fullName;
  String? telebirrNumber;
  String? nationalId;
  DateTime? dateOfBirth;
  String? gender;
  String? region;
  String? avatarType;
  String? avatarValue;
  UserProfile? profile;

  bool get isTelebirrConnected =>
      telebirrNumber != null && telebirrNumber!.isNotEmpty;
  bool get hasKycProfile => fullName != null && fullName!.isNotEmpty;

  // Available T-Bill pools in the market
  List<TBillPool> pools = [
    TBillPool(
      id: "28_day_tbill",
      title: "28-Day T-Bill",
      yieldRate: 8.5,
      progress: 0.73,
      minInvestment: 500.0,
      type: "Fixed Term",
      termInDays: 28,
    ),
    TBillPool(
      id: "91_day_tbill",
      title: "91-Day T-Bill",
      yieldRate: 9.2,
      progress: 0.45,
      minInvestment: 1000.0,
      type: "Daily Liquidity",
      termInDays: 91,
    ),
    TBillPool(
      id: "182_day_tbill",
      title: "182-Day T-Bill",
      yieldRate: 10.5,
      progress: 0.28,
      minInvestment: 5000.0,
      type: "Fixed Term",
      termInDays: 182,
    ),
    // Commercial Bonds — gives the "Commercial Bonds" filter real examples.
    TBillPool(
      id: "commercial_bond_90",
      title: "90-Day Commercial Bond",
      yieldRate: 11.2,
      progress: 0.62,
      minInvestment: 2000.0,
      type: "Fixed Term",
      termInDays: 90,
    ),
    TBillPool(
      id: "commercial_bond_270",
      title: "270-Day Commercial Bond",
      yieldRate: 13.8,
      progress: 0.4,
      minInvestment: 15000.0,
      type: "Fixed Term",
      termInDays: 270,
    ),
    // Other Bonds — gives the "Other Bonds" filter real examples.
    TBillPool(
      id: "municipal_bond_180",
      title: "180-Day Municipal Bond",
      yieldRate: 9.0,
      progress: 0.5,
      minInvestment: 3000.0,
      type: "Daily Liquidity",
      termInDays: 180,
    ),
    TBillPool(
      id: "corporate_note_60",
      title: "60-Day Corporate Note",
      yieldRate: 7.5,
      progress: 0.8,
      minInvestment: 1500.0,
      type: "Fixed Term",
      termInDays: 60,
    ),
  ];

  // User's active holdings — starts empty for a newly registered user.
  List<Holding> holdings = [];

  // User's withdrawal history
  List<WithdrawalRecord> withdrawals = [];

  // User's notification feed
  List<AppNotification> notifications = [
    AppNotification(
      id: "notif_1",
      title: "Welcome to ብር Gebeya",
      description:
          "Start investing in secure, high-yield Ethiopian Treasury Bills backed by the National Bank.",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: "notif_2",
      title: "Telebirr Account Connected",
      description:
          "Your Telebirr wallet has been linked successfully. You can now deposit and withdraw funds.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  // Getters
  double get totalInvested {
    double total = 0.0;
    for (var holding in holdings) {
      total += holding.investedAmount;
    }
    return total;
  }

  double get expectedReturn {
    double total = 0.0;
    for (var holding in holdings) {
      total += holding.expectedReturn;
    }
    return total;
  }

  int get nextMaturityDays {
    if (holdings.isEmpty) return 0;
    int minDays = 9999;
    for (var holding in holdings) {
      final days = holding.daysRemaining;
      if (days < minDays) {
        minDays = days;
      }
    }
    return minDays == 9999 ? 0 : minDays;
  }

  // Actions
  void connectTelebirr(String number) {
    telebirrNumber = number;
    notifications.insert(
      0,
      AppNotification(
        id: "notif_tb_${DateTime.now().millisecondsSinceEpoch}",
        title: "Telebirr Linked Successfully",
        description:
            "Your Telebirr number $telebirrNumber is now connected for fast transactions.",
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  bool addInvestment(TBillPool pool, double amount) {
    if (amount < pool.minInvestment) return false;

    final expected =
        amount + (amount * (pool.yieldRate / 100) * (pool.termInDays / 365));

    final newHolding = Holding(
      id: "holding_${DateTime.now().millisecondsSinceEpoch}",
      poolId: pool.id,
      title: pool.title,
      investedAmount: amount,
      expectedReturn: double.parse(expected.toStringAsFixed(2)),
      yieldRate: pool.yieldRate,
      purchaseDate: DateTime.now(),
      termInDays: pool.termInDays,
    );

    holdings.add(newHolding);

    notifications.insert(
      0,
      AppNotification(
        id: "notif_inv_${DateTime.now().millisecondsSinceEpoch}",
        title: "Investment Confirmed",
        description:
            "Successfully invested ETB ${amount.toStringAsFixed(0)} in ${pool.title}.",
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  bool withdraw(double amount) {
    if (amount <= 0 || holdings.isEmpty) return false;

    double totalHold = totalInvested;
    if (amount > totalHold) return false;

    double remainingToWithdraw = amount;
    List<Holding> toRemove = [];

    for (int i = 0; i < holdings.length; i++) {
      final h = holdings[i];
      if (h.investedAmount <= remainingToWithdraw) {
        remainingToWithdraw -= h.investedAmount;
        toRemove.add(h);
      } else {
        final updatedHolding = Holding(
          id: h.id,
          poolId: h.poolId,
          title: h.title,
          investedAmount: h.investedAmount - remainingToWithdraw,
          expectedReturn:
              h.expectedReturn -
              (remainingToWithdraw *
                  (1 + (h.yieldRate / 100) * (h.termInDays / 365))),
          yieldRate: h.yieldRate,
          purchaseDate: h.purchaseDate,
          termInDays: h.termInDays,
        );
        holdings[i] = updatedHolding;
        remainingToWithdraw = 0;
        break;
      }
    }

    for (var h in toRemove) {
      holdings.remove(h);
    }

    notifications.insert(
      0,
      AppNotification(
        id: "notif_wd_${DateTime.now().millisecondsSinceEpoch}",
        title: "Withdrawal Successful",
        description:
            "Withdrew ETB ${amount.toStringAsFixed(0)} to your Telebirr wallet.",
        timestamp: DateTime.now(),
      ),
    );

    withdrawals.insert(
      0,
      WithdrawalRecord(
        id: "withdrawal_${DateTime.now().millisecondsSinceEpoch}",
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  void markNotificationAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    notifications.clear();
    notifyListeners();
  }

  /// Refresh user profile from Supabase if available.
  Future<void> refreshFromSupabase() async {
    try {
      final repository = SupabaseAppRepository();
      final data = await repository.fetchProfile();
      if (data != null) {
        fullName = (data['full_name'] ?? fullName) as String?;
        telebirrNumber = (data['telebirr_number'] ?? telebirrNumber) as String?;
        profile = UserProfile(
          email: data['email'] as String?,
          phoneNumber: data['phone_number'] as String?,
        );
      }
    } catch (_) {
      // ignore errors and keep local state
    } finally {
      notifyListeners();
    }
  }

  /// Updates profile fields locally.
  Future<void> updateProfile({
    required String userName,
    required String fullNameValue,
    String? telebirrNumberValue,
    String? nationalIdValue,
    DateTime? dateOfBirthValue,
    String? genderValue,
    String? regionValue,
    String? avatarTypeValue,
    String? avatarValueValue,
    String? email,
    String? phoneNumber,
  }) async {
    this.userName = userName;
    fullName = fullNameValue;
    // Omitted (null) fields preserve whatever was already set, rather than
    // wiping it out — callers like the KYC form only pass the fields they
    // collect, and shouldn't clear e.g. the Telebirr number set moments
    // earlier by the Telebirr-connect step.
    telebirrNumber = telebirrNumberValue ?? telebirrNumber;
    nationalId = nationalIdValue ?? nationalId;
    dateOfBirth = dateOfBirthValue ?? dateOfBirth;
    gender = genderValue ?? gender;
    region = regionValue ?? region;
    avatarType = avatarTypeValue ?? avatarType;
    avatarValue = avatarValueValue ?? avatarValue;
    profile = UserProfile(
      email: email ?? profile?.email,
      phoneNumber: phoneNumber ?? profile?.phoneNumber,
    );
    notifyListeners();

    // Persist to Supabase when a session exists (no-op if not signed in).
    try {
      await SupabaseAppRepository().saveProfile(
        userName: userName,
        fullName: fullName,
        telebirrNumber: telebirrNumber,
        email: email,
        phoneNumber: phoneNumber,
      );
    } catch (_) {
      // Keep local state even if the network write fails.
    }
  }

  /// Builds a plain-text snapshot of the live pools and the user's holdings,
  /// used as context for the AI investment advisor.
  String buildAdvisorContext() {
    final buffer = StringBuffer();
    buffer.writeln('USER PROFILE');
    buffer.writeln('- Name: $userName');
    if (region != null) buffer.writeln('- Region: $region');
    buffer.writeln(
      '- Telebirr wallet connected: ${isTelebirrConnected ? "yes" : "no"}',
    );
    buffer.writeln();

    buffer.writeln('AVAILABLE T-BILL POOLS (the user can invest in these):');
    for (final p in pools) {
      buffer.writeln(
        '- ${p.title}: ${p.yieldRate.toStringAsFixed(1)}% p.a., '
        '${p.termInDays}-day term, type ${p.type}, '
        'min ETB ${p.minInvestment.toStringAsFixed(0)}, '
        '${(p.progress * 100).toStringAsFixed(0)}% funded',
      );
    }
    buffer.writeln();

    buffer.writeln('USER CURRENT HOLDINGS:');
    if (holdings.isEmpty) {
      buffer.writeln('- (none yet — the user has not invested)');
    } else {
      for (final h in holdings) {
        buffer.writeln(
          '- ${h.title}: invested ETB ${h.investedAmount.toStringAsFixed(0)}, '
          'expected return ETB ${h.expectedReturn.toStringAsFixed(0)}, '
          '${h.yieldRate.toStringAsFixed(1)}% p.a., '
          '${h.daysRemaining} of ${h.termInDays} days remaining',
        );
      }
      buffer.writeln(
        'Totals: invested ETB ${totalInvested.toStringAsFixed(0)}, '
        'expected return ETB ${expectedReturn.toStringAsFixed(0)}, '
        'next maturity in $nextMaturityDays days.',
      );
    }
    return buffer.toString();
  }
}

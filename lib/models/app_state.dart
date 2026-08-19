import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // CSD account — created by a broker once KYC is reviewed; see
  // birr_gebeya/migrations/004_broker_dashboard.sql. Populated by
  // refreshFromSupabase() and kept live by subscribeToProfileUpdates().
  String? csdAccountNumber;
  String csdAccountStatus = 'pending';
  RealtimeChannel? _profileChannel;

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

  // User's notification feed. Populated from Supabase (admin broadcasts +
  // anything addressed to this user) by refreshFromSupabase(); actions like
  // connectTelebirr()/addInvestment()/withdraw() below insert local-only
  // entries on top of whatever was loaded.
  List<AppNotification> notifications = [];

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

  /// Places an order for [pool]. Requires a CSD account to already exist —
  /// it's the broker-issued proof of ownership the order is routed against
  /// (birr_gebeya/migrations/004_broker_dashboard.sql) — and writes a real
  /// `orders` row the broker dashboard verifies against the SMS the broker
  /// receives, before appending the (still locally-tracked) holding.
  Future<bool> addInvestment(TBillPool pool, double amount) async {
    if (amount < pool.minInvestment) return false;
    final csdAccount = csdAccountNumber;
    if (csdAccount == null || csdAccount.isEmpty) return false;

    final orderPlaced = await SupabaseAppRepository().createOrder(
      poolId: pool.id,
      assetName: pool.title,
      amount: amount,
      csdAccountNumber: csdAccount,
      userFullName: fullName ?? userName,
    );
    if (!orderPlaced) return false;

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

  /// Refresh user profile and notifications from Supabase if available.
  Future<void> refreshFromSupabase() async {
    try {
      final repository = SupabaseAppRepository();
      final data = await repository.fetchProfile();
      if (data != null) {
        fullName = (data['full_name'] ?? fullName) as String?;
        telebirrNumber = (data['telebirr_number'] ?? telebirrNumber) as String?;
        csdAccountNumber = data['csd_account_number'] as String?;
        csdAccountStatus = (data['csd_account_status'] as String?) ?? 'pending';
        profile = UserProfile(
          email: data['email'] as String?,
          phoneNumber: data['phone_number'] as String?,
        );
      }

      final rows = await repository.fetchNotifications();
      final existingById = {for (final n in notifications) n.id: n};
      final remoteNotifications = rows.map((row) {
        final id = row['id'] as String;
        return AppNotification(
          id: id,
          title: row['title'] as String,
          description: row['description'] as String,
          timestamp: DateTime.parse(row['created_at'] as String),
          isRead: existingById[id]?.isRead ?? false,
        );
      });

      // Local-only entries (Telebirr/investment/withdrawal confirmations
      // generated by the actions below) all use a "notif_" id prefix, which
      // a Supabase row id (a uuid) never does — keep those, replace
      // everything else with the freshly-fetched remote set.
      final localOnly = notifications.where((n) => n.id.startsWith('notif_'));
      notifications = [...remoteNotifications, ...localOnly]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      // ignore errors and keep local state
    } finally {
      notifyListeners();
    }
  }

  /// Keeps [csdAccountNumber]/[csdAccountStatus] live once a broker creates
  /// the account, instead of waiting for the next manual/post-sign-in
  /// refreshFromSupabase() call. Safe to call more than once (e.g. app
  /// resume) — it replaces any previous subscription rather than stacking.
  void subscribeToProfileUpdates(String userId) {
    _profileChannel?.unsubscribe();
    _profileChannel = Supabase.instance.client
        .channel('profile-csd-$userId')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: 'UPDATE',
            schema: 'public',
            table: 'profiles',
            filter: 'id=eq.$userId',
          ),
          (payload, [ref]) {
            final updated = payload['new'] as Map<String, dynamic>?;
            if (updated == null) return;
            csdAccountNumber = updated['csd_account_number'] as String?;
            csdAccountStatus =
                (updated['csd_account_status'] as String?) ?? csdAccountStatus;
            notifyListeners();
          },
        );
    _profileChannel!.subscribe();
  }

  /// Tears down the profile Realtime subscription — call this on sign-out
  /// so a stale channel doesn't keep streaming a signed-out user's updates.
  void unsubscribeFromProfileUpdates() {
    _profileChannel?.unsubscribe();
    _profileChannel = null;
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
        nationalId: nationalId,
        region: region,
        gender: gender,
        dateOfBirth: dateOfBirth,
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

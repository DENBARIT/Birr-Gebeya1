/// Minimal in-app localization: a language enum plus a lookup table of
/// translated strings, keyed by a short id. Not a full flutter_localizations
/// / ARB setup — this covers the dashboard screen's visible strings as a
/// first working slice. Extend `_strings` and reuse [tr] to cover more
/// screens the same way.
///
/// Translations below are a best-effort starting point, not reviewed by a
/// native speaker — have someone fluent check wording/naturalness before
/// shipping.
enum AppLanguage { english, amharic, afaanOromo, tigrinya }

extension AppLanguageMeta on AppLanguage {
  /// Name shown in the language picker, in its own language.
  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.amharic:
        return 'አማርኛ';
      case AppLanguage.afaanOromo:
        return 'Afaan Oromoo';
      case AppLanguage.tigrinya:
        return 'ትግርኛ';
    }
  }

  /// Short code persisted to disk.
  String get storageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.amharic:
        return 'am';
      case AppLanguage.afaanOromo:
        return 'om';
      case AppLanguage.tigrinya:
        return 'ti';
    }
  }

  static AppLanguage fromStorageCode(String? code) {
    switch (code) {
      case 'am':
        return AppLanguage.amharic;
      case 'om':
        return AppLanguage.afaanOromo;
      case 'ti':
        return AppLanguage.tigrinya;
      default:
        return AppLanguage.english;
    }
  }
}

const Map<String, Map<AppLanguage, String>> _strings = {
  'goodMorning': {
    AppLanguage.english: 'Good morning,',
    AppLanguage.amharic: 'እንደምን አደሩ,',
    AppLanguage.afaanOromo: 'Akkam bulte,',
    AppLanguage.tigrinya: 'ደሓን ሓዲርኩም,',
  },
  'goodAfternoon': {
    AppLanguage.english: 'Good afternoon,',
    AppLanguage.amharic: 'እንደምን ዋሉ,',
    AppLanguage.afaanOromo: 'Akkam oolte,',
    AppLanguage.tigrinya: 'ደሓን ውዓልኩም,',
  },
  'goodEvening': {
    AppLanguage.english: 'Good evening,',
    AppLanguage.amharic: 'እንደምን አመሹ,',
    AppLanguage.afaanOromo: 'Akkam galgalte,',
    AppLanguage.tigrinya: 'ደሓን ምሸት,',
  },
  'goodNight': {
    AppLanguage.english: 'Good night,',
    AppLanguage.amharic: 'መልካም ሌሊት,',
    AppLanguage.afaanOromo: 'Halkan gaarii,',
    AppLanguage.tigrinya: 'ደሓን ሕደር,',
  },
  'totalInvested': {
    AppLanguage.english: 'TOTAL INVESTED',
    AppLanguage.amharic: 'ጠቅላላ ኢንቨስትመንት',
    AppLanguage.afaanOromo: 'WALIIGALA INVESTIMENTII',
    AppLanguage.tigrinya: 'ጠቕላላ ወፍሪ',
  },
  'expectedReturn': {
    AppLanguage.english: 'Expected Return',
    AppLanguage.amharic: 'የሚጠበቅ ትርፍ',
    AppLanguage.afaanOromo: 'Galii Eegamu',
    AppLanguage.tigrinya: 'ትጽቢት ዝግበረሉ ትርፊ',
  },
  'nextMaturity': {
    AppLanguage.english: 'Next Maturity',
    AppLanguage.amharic: 'ቀጣይ የመክፈያ ጊዜ',
    AppLanguage.afaanOromo: 'Guyyaa Xumuraa Itti Aanu',
    AppLanguage.tigrinya: 'ቀጻሊ ግዜ ብስለት',
  },
  'treasuryBillPools': {
    AppLanguage.english: 'Treasury bill pools',
    AppLanguage.amharic: 'የግምጃ ቤት ሰነድ ገንዳዎች',
    AppLanguage.afaanOromo: 'Kuusaa Waraqaa Baankii Mootummaa',
    AppLanguage.tigrinya: 'ቦታታት ናይ ግምጃ ቤት ሰነድ',
  },
  'days': {
    AppLanguage.english: 'Days',
    AppLanguage.amharic: 'ቀናት',
    AppLanguage.afaanOromo: 'Guyyoota',
    AppLanguage.tigrinya: 'መዓልትታት',
  },
  'navHome': {
    AppLanguage.english: 'Home',
    AppLanguage.amharic: 'መነሻ',
    AppLanguage.afaanOromo: 'Mana',
    AppLanguage.tigrinya: 'ገዛ',
  },
  'navInvest': {
    AppLanguage.english: 'Invest',
    AppLanguage.amharic: 'ኢንቨስት',
    AppLanguage.afaanOromo: 'Invest',
    AppLanguage.tigrinya: 'ውፍሪ',
  },
  'navPortfolio': {
    AppLanguage.english: 'Portfolio',
    AppLanguage.amharic: 'ፖርትፎሊዮ',
    AppLanguage.afaanOromo: 'Portfolio',
    AppLanguage.tigrinya: 'ፖርትፎልዮ',
  },
  'navNotifications': {
    AppLanguage.english: 'Alerts',
    AppLanguage.amharic: 'ማሳወቂያዎች',
    AppLanguage.afaanOromo: 'Beeksisa',
    AppLanguage.tigrinya: 'ማስታወቂያታት',
  },
  'navProfile': {
    AppLanguage.english: 'Profile',
    AppLanguage.amharic: 'መገለጫ',
    AppLanguage.afaanOromo: 'Profaayilii',
    AppLanguage.tigrinya: 'ፕሮፋይል',
  },
  'withdraw': {
    AppLanguage.english: 'Withdraw',
    AppLanguage.amharic: 'አውጣ',
    AppLanguage.afaanOromo: 'Baasi',
    AppLanguage.tigrinya: 'አውጽእ',
  },
  'askAi': {
    AppLanguage.english: 'Ask AI',
    AppLanguage.amharic: 'AI ጠይቅ',
    AppLanguage.afaanOromo: 'AI Gaafadhu',
    AppLanguage.tigrinya: 'ንAI ሕተት',
  },
  'chooseLanguage': {
    AppLanguage.english: 'Choose language',
    AppLanguage.amharic: 'ቋንቋ ይምረጡ',
    AppLanguage.afaanOromo: 'Afaan filadhu',
    AppLanguage.tigrinya: 'ቋንቋ ምረጽ',
  },
};

/// Looks up [key] for [lang], falling back to English, then to the key
/// itself if it's missing from the table entirely.
String tr(AppLanguage lang, String key) {
  final entry = _strings[key];
  if (entry == null) return key;
  return entry[lang] ?? entry[AppLanguage.english] ?? key;
}

/// Masks a contact value (email or phone) before it goes into a debug log —
/// keeps enough to distinguish accounts during debugging without printing
/// PII in full. `debugPrint` output lands in device logcat / crash reports,
/// which is readable without a debugger attached (e.g. via `adb logcat`).
String maskContact(String value) {
  if (value.length <= 4) return '*' * value.length;
  return '${value.substring(0, 2)}${'*' * (value.length - 4)}${value.substring(value.length - 2)}';
}

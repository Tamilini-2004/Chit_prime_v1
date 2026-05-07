class AadhaarRegistry {
  static const Map<String, String> _records = {
    'haris': '123456780123',
    'priya sharma': '234567890123',
    'amit patel': '345678901234',
    'sunita devi': '456789012345',
    'rajesh kumar': '567890123456',
    'meena lakshmi': '678901234567',
    'vignesh raman': '789012345678',
    'deepa nair': '890123456789',
    'karthik sri': '901234567890',
    'farzana ali': '912345678901',
    'tamilini': '923456789012',
    'nisha reddy': '934567890123',
  };

  static Map<String, String> get records => Map.unmodifiable(_records);

  static String normalizeName(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static bool isValidFormat(String value) =>
      RegExp(r'^\d{12}$').hasMatch(digitsOnly(value));

  static bool matches(String name, String aadhaarNumber) {
    final expected = _records[normalizeName(name)];
    return expected != null && expected == digitsOnly(aadhaarNumber);
  }
}

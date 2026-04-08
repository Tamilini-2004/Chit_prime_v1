// Testing bypass — set isEnabled = false for production
class TestBypass {
  static bool isEnabled = true;
  static bool skipOtpVerification = true;
  static bool acceptAnyLogin = true;
  static bool skipAllValidation = true;
  static bool skipEligibilityChecks = true;
  static bool autoCreateUser = true;

  static const String testAdminEmail = 'test@admin.com';
  static const String testMemberPhone = '+919999999999';
  static const String testForemanPhone = '+919876543210';
  static const String anyOtp = '123456';
}

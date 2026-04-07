class UserModel {
  final String userId;
  final String phoneNumber;
  final String fullName;
  final String? email;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? bankAccount;
  final String? ifscCode;
  final String? bankName;
  final int creditScore;
  final String verificationStatus;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.userId,
    required this.phoneNumber,
    required this.fullName,
    this.email,
    this.aadhaarNumber,
    this.panNumber,
    this.bankAccount,
    this.ifscCode,
    this.bankName,
    this.creditScore = 0,
    this.verificationStatus = 'pending',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['user_id'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        fullName: json['full_name'] ?? '',
        email: json['email'],
        aadhaarNumber: json['aadhaar_number'],
        panNumber: json['pan_number'],
        bankAccount: json['bank_account'],
        ifscCode: json['ifsc_code'],
        bankName: json['bank_name'],
        creditScore: json['credit_score'] ?? 0,
        verificationStatus: json['verification_status'] ?? 'pending',
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updated_at'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'phone_number': phoneNumber,
        'full_name': fullName,
        'email': email,
        'aadhaar_number': aadhaarNumber,
        'pan_number': panNumber,
        'bank_account': bankAccount,
        'ifsc_code': ifscCode,
        'bank_name': bankName,
        'credit_score': creditScore,
        'verification_status': verificationStatus,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? fullName,
    String? email,
    String? aadhaarNumber,
    String? panNumber,
    String? bankAccount,
    String? ifscCode,
    String? bankName,
    int? creditScore,
    String? verificationStatus,
    bool? isActive,
  }) =>
      UserModel(
        userId: userId,
        phoneNumber: phoneNumber,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
        panNumber: panNumber ?? this.panNumber,
        bankAccount: bankAccount ?? this.bankAccount,
        ifscCode: ifscCode ?? this.ifscCode,
        bankName: bankName ?? this.bankName,
        creditScore: creditScore ?? this.creditScore,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

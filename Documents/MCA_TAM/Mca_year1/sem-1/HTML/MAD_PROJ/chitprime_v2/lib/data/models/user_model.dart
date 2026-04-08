import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phone;
  final String name;
  final String email;
  final String role;
  final int creditScore;
  final String kycStatus;
  final String accountStatus;
  final String aadhaarLast4;
  final String panMasked;
  final String bankMasked;
  final String bankName;
  final String ifsc;
  final String city;
  final String state;
  final String fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOnline;

  const UserModel({
    required this.uid, required this.phone, required this.name,
    this.email = '', this.role = 'member', this.creditScore = 650,
    this.kycStatus = 'verified', this.accountStatus = 'active',
    this.aadhaarLast4 = '', this.panMasked = '', this.bankMasked = '',
    this.bankName = '', this.ifsc = '', this.city = '', this.state = '',
    this.fcmToken = '', required this.createdAt, required this.updatedAt,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    uid: j['uid'] ?? '',
    phone: j['phone'] ?? '',
    name: j['name'] ?? 'Test User',
    email: j['email'] ?? '',
    role: j['role'] ?? 'member',
    creditScore: (j['creditScore'] as num?)?.toInt() ?? 650,
    kycStatus: j['kycStatus'] ?? 'verified',
    accountStatus: j['accountStatus'] ?? 'active',
    aadhaarLast4: j['aadhaarLast4'] ?? '',
    panMasked: j['panMasked'] ?? '',
    bankMasked: j['bankMasked'] ?? '',
    bankName: j['bankName'] ?? '',
    ifsc: j['ifsc'] ?? '',
    city: j['city'] ?? '',
    state: j['state'] ?? '',
    fcmToken: j['fcmToken'] ?? '',
    createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (j['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    isOnline: j['isOnline'] ?? false,
  );

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['uid'] = doc.id;
    return UserModel.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
    'uid': uid, 'phone': phone, 'name': name, 'email': email,
    'role': role, 'creditScore': creditScore, 'kycStatus': kycStatus,
    'accountStatus': accountStatus, 'aadhaarLast4': aadhaarLast4,
    'panMasked': panMasked, 'bankMasked': bankMasked, 'bankName': bankName,
    'ifsc': ifsc, 'city': city, 'state': state, 'fcmToken': fcmToken,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'isOnline': isOnline,
  };

  UserModel copyWith({String? name, String? email, String? role, int? creditScore,
    String? kycStatus, String? accountStatus, String? bankName, String? ifsc,
    String? bankMasked, String? fcmToken, bool? isOnline}) =>
      UserModel(
        uid: uid, phone: phone,
        name: name ?? this.name, email: email ?? this.email,
        role: role ?? this.role, creditScore: creditScore ?? this.creditScore,
        kycStatus: kycStatus ?? this.kycStatus, accountStatus: accountStatus ?? this.accountStatus,
        aadhaarLast4: aadhaarLast4, panMasked: panMasked,
        bankMasked: bankMasked ?? this.bankMasked, bankName: bankName ?? this.bankName,
        ifsc: ifsc ?? this.ifsc, city: city, state: state,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt, updatedAt: DateTime.now(),
        isOnline: isOnline ?? this.isOnline,
      );

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isForeman => role == 'foreman' || isAdmin;
  bool get isSuspended => accountStatus == 'suspended';
}

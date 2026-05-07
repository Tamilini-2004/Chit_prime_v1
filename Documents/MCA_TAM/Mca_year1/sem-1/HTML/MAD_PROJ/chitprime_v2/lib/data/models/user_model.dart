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
  final String aadhaarNumber;
  final String aadhaarLast4;
  final String aadhaarImageUrl;
  final String aadhaarImageData;
  final String panMasked;
  final String bankMasked;
  final String bankName;
  final String ifsc;
  final String city;
  final String state;
  final String fcmToken;
  final bool registrationCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? kycSubmittedAt;
  final bool isOnline;

  const UserModel({
    required this.uid, required this.phone, required this.name,
    this.email = '', this.role = 'member', this.creditScore = 650,
    this.kycStatus = 'verified', this.accountStatus = 'active',
    this.aadhaarNumber = '', this.aadhaarLast4 = '', this.aadhaarImageUrl = '',
    this.aadhaarImageData = '',
    this.panMasked = '', this.bankMasked = '',
    this.bankName = '', this.ifsc = '', this.city = '', this.state = '',
    this.fcmToken = '', this.registrationCompleted = true,
    required this.createdAt, required this.updatedAt, this.kycSubmittedAt,
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
    aadhaarNumber: j['aadhaarNumber'] ?? '',
    aadhaarLast4: j['aadhaarLast4'] ?? '',
    aadhaarImageUrl: j['aadhaarImageUrl'] ?? '',
    aadhaarImageData: j['aadhaarImageData'] ?? '',
    panMasked: j['panMasked'] ?? '',
    bankMasked: j['bankMasked'] ?? '',
    bankName: j['bankName'] ?? '',
    ifsc: j['ifsc'] ?? '',
    city: j['city'] ?? '',
    state: j['state'] ?? '',
    fcmToken: j['fcmToken'] ?? '',
    registrationCompleted: j['registrationCompleted'] ?? true,
    createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (j['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    kycSubmittedAt: (j['kycSubmittedAt'] as Timestamp?)?.toDate(),
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
    'accountStatus': accountStatus, 'aadhaarNumber': aadhaarNumber,
    'aadhaarLast4': aadhaarLast4, 'aadhaarImageUrl': aadhaarImageUrl,
    'aadhaarImageData': aadhaarImageData,
    'panMasked': panMasked, 'bankMasked': bankMasked, 'bankName': bankName,
    'ifsc': ifsc, 'city': city, 'state': state, 'fcmToken': fcmToken,
    'registrationCompleted': registrationCompleted,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'kycSubmittedAt': kycSubmittedAt == null ? null : Timestamp.fromDate(kycSubmittedAt!),
    'isOnline': isOnline,
  };

  UserModel copyWith({String? name, String? email, String? role, int? creditScore,
    String? kycStatus, String? accountStatus, String? bankName, String? ifsc,
    String? bankMasked, String? fcmToken, bool? isOnline,
    String? aadhaarNumber, String? aadhaarImageUrl, String? aadhaarImageData,
    bool? registrationCompleted,
    DateTime? kycSubmittedAt}) =>
      UserModel(
        uid: uid, phone: phone,
        name: name ?? this.name, email: email ?? this.email,
        role: role ?? this.role, creditScore: creditScore ?? this.creditScore,
        kycStatus: kycStatus ?? this.kycStatus, accountStatus: accountStatus ?? this.accountStatus,
        aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
        aadhaarLast4: aadhaarLast4,
        aadhaarImageUrl: aadhaarImageUrl ?? this.aadhaarImageUrl,
        aadhaarImageData: aadhaarImageData ?? this.aadhaarImageData,
        panMasked: panMasked,
        bankMasked: bankMasked ?? this.bankMasked, bankName: bankName ?? this.bankName,
        ifsc: ifsc ?? this.ifsc, city: city, state: state,
        fcmToken: fcmToken ?? this.fcmToken,
        registrationCompleted: registrationCompleted ?? this.registrationCompleted,
        createdAt: createdAt, updatedAt: DateTime.now(),
        kycSubmittedAt: kycSubmittedAt ?? this.kycSubmittedAt,
        isOnline: isOnline ?? this.isOnline,
      );

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isForeman => role == 'foreman' || isAdmin;
  bool get isSuspended => accountStatus == 'suspended';
  bool get needsRegistration => !registrationCompleted;
}

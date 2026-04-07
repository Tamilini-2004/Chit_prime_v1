class NotificationModel {
  final String notificationId;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionUrl;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationId: json['notification_id'] ?? '',
        userId: json['user_id'] ?? '',
        type: json['type'] ?? 'general',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        isRead: json['is_read'] ?? false,
        actionUrl: json['action_url'],
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        notificationId: notificationId,
        userId: userId,
        type: type,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        actionUrl: actionUrl,
        createdAt: createdAt,
      );
}

class FraudAlertModel {
  final String alertId;
  final String userId;
  final String userName;
  final String alertType;
  final String severity;
  final String description;
  final String evidence;
  final String status;
  final double riskScore;
  final DateTime detectedAt;
  final DateTime? resolvedAt;

  const FraudAlertModel({
    required this.alertId,
    required this.userId,
    required this.userName,
    required this.alertType,
    required this.severity,
    required this.description,
    required this.evidence,
    required this.status,
    required this.riskScore,
    required this.detectedAt,
    this.resolvedAt,
  });

  factory FraudAlertModel.fromJson(Map<String, dynamic> json) =>
      FraudAlertModel(
        alertId: json['alert_id'] ?? '',
        userId: json['user_id'] ?? '',
        userName: json['user_name'] ?? '',
        alertType: json['alert_type'] ?? '',
        severity: json['severity'] ?? 'low',
        description: json['description'] ?? '',
        evidence: json['evidence'] ?? '',
        status: json['status'] ?? 'open',
        riskScore: (json['risk_score'] ?? 0).toDouble(),
        detectedAt: DateTime.parse(
            json['detected_at'] ?? DateTime.now().toIso8601String()),
        resolvedAt: json['resolved_at'] != null
            ? DateTime.parse(json['resolved_at'])
            : null,
      );
}

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String toUid;
  final String fromUid;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String relatedId;
  final String relatedType;
  final String actionRoute;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId, required this.toUid, this.fromUid = 'system',
    required this.type, required this.title, required this.message,
    this.isRead = false, this.relatedId = '', this.relatedType = '',
    this.actionRoute = '', required this.createdAt,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id, toUid: j['toUid'] ?? '',
      fromUid: j['fromUid'] ?? 'system', type: j['type'] ?? 'system',
      title: j['title'] ?? '', message: j['message'] ?? '',
      isRead: j['isRead'] ?? false, relatedId: j['relatedId'] ?? '',
      relatedType: j['relatedType'] ?? '', actionRoute: j['actionRoute'] ?? '',
      createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'notificationId': notificationId, 'toUid': toUid, 'fromUid': fromUid,
    'type': type, 'title': title, 'message': message, 'isRead': isRead,
    'relatedId': relatedId, 'relatedType': relatedType, 'actionRoute': actionRoute,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class MessageModel {
  final String messageId;
  final String conversationId;
  final String fromUid;
  final String fromName;
  final String fromRole;
  final String toUid;
  final String message;
  final bool isRead;
  final String attachmentUrl;
  final DateTime sentAt;

  const MessageModel({
    required this.messageId, required this.conversationId,
    required this.fromUid, required this.fromName, this.fromRole = 'member',
    required this.toUid, required this.message, this.isRead = false,
    this.attachmentUrl = '', required this.sentAt,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: doc.id, conversationId: j['conversationId'] ?? '',
      fromUid: j['fromUid'] ?? '', fromName: j['fromName'] ?? '',
      fromRole: j['fromRole'] ?? 'member', toUid: j['toUid'] ?? '',
      message: j['message'] ?? '', isRead: j['isRead'] ?? false,
      attachmentUrl: j['attachmentUrl'] ?? '',
      sentAt: (j['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'messageId': messageId, 'conversationId': conversationId,
    'fromUid': fromUid, 'fromName': fromName, 'fromRole': fromRole,
    'toUid': toUid, 'message': message, 'isRead': isRead,
    'attachmentUrl': attachmentUrl, 'sentAt': Timestamp.fromDate(sentAt),
  };
}

class FraudAlertModel {
  final String alertId;
  final String userId;
  final String userName;
  final String groupId;
  final String alertType;
  final String severity;
  final String description;
  final Map<String, dynamic> evidence;
  final double aiConfidence;
  final String status;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String resolvedByUid;
  final String resolutionNotes;

  const FraudAlertModel({
    required this.alertId, required this.userId, required this.userName,
    this.groupId = '', required this.alertType, required this.severity,
    required this.description, this.evidence = const {}, this.aiConfidence = 0.8,
    this.status = 'open', required this.detectedAt, this.resolvedAt,
    this.resolvedByUid = '', this.resolutionNotes = '',
  });

  factory FraudAlertModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return FraudAlertModel(
      alertId: doc.id, userId: j['userId'] ?? '', userName: j['userName'] ?? '',
      groupId: j['groupId'] ?? '', alertType: j['alertType'] ?? '',
      severity: j['severity'] ?? 'low', description: j['description'] ?? '',
      evidence: Map<String, dynamic>.from(j['evidence'] ?? {}),
      aiConfidence: (j['aiConfidence'] ?? 0.8).toDouble(),
      status: j['status'] ?? 'open',
      detectedAt: (j['detectedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (j['resolvedAt'] as Timestamp?)?.toDate(),
      resolvedByUid: j['resolvedByUid'] ?? '',
      resolutionNotes: j['resolutionNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'alertId': alertId, 'userId': userId, 'userName': userName,
    'groupId': groupId, 'alertType': alertType, 'severity': severity,
    'description': description, 'evidence': evidence, 'aiConfidence': aiConfidence,
    'status': status, 'detectedAt': Timestamp.fromDate(detectedAt),
    'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    'resolvedByUid': resolvedByUid, 'resolutionNotes': resolutionNotes,
  };
}

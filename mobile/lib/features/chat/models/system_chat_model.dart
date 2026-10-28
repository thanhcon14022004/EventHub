class SystemChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'Customer', 'Provider', 'Admin'
  final bool isFromAdmin;
  final String text;
  final DateTime createdAt;

  SystemChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.isFromAdmin,
    required this.text,
    required this.createdAt,
  });

  String get timeFormatted {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) {
      final hour = createdAt.hour.toString().padLeft(2, '0');
      final minute = createdAt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${createdAt.day}/${createdAt.month}';
  }

  SystemChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderRole,
    bool? isFromAdmin,
    String? text,
    DateTime? createdAt,
  }) {
    return SystemChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      isFromAdmin: isFromAdmin ?? this.isFromAdmin,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderRole': senderRole,
    'isFromAdmin': isFromAdmin,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SystemChatMessage.fromMap(Map<String, dynamic> map) => SystemChatMessage(
    id: map['id']?.toString() ?? '',
    senderId: map['senderId']?.toString() ?? '',
    senderName: map['senderName']?.toString() ?? '',
    senderRole: map['senderRole']?.toString() ?? 'Customer',
    isFromAdmin: map['isFromAdmin'] as bool? ?? false,
    text: map['text']?.toString() ?? '',
    createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class SystemConversation {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userRole; // 'Customer', 'Provider'
  final String? userAvatarUrl;
  final List<SystemChatMessage> messages;
  final int unreadByAdmin;
  final int unreadByUser;
  final String lastMessage;
  final DateTime updatedAt;
  final String status; // 'waiting', 'in_progress', 'resolved'
  final String topic; // 'Tư vấn dịch vụ', 'Chính sách hoàn cọc', ...

  SystemConversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userRole,
    this.userAvatarUrl,
    required this.messages,
    this.unreadByAdmin = 0,
    this.unreadByUser = 0,
    required this.lastMessage,
    required this.updatedAt,
    this.status = 'waiting',
    this.topic = 'Hỗ trợ chung',
  });

  String get timeFormatted {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) {
      final hour = updatedAt.hour.toString().padLeft(2, '0');
      final minute = updatedAt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${updatedAt.day}/${updatedAt.month}';
  }

  SystemConversation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userRole,
    String? userAvatarUrl,
    List<SystemChatMessage>? messages,
    int? unreadByAdmin,
    int? unreadByUser,
    String? lastMessage,
    DateTime? updatedAt,
    String? status,
    String? topic,
  }) {
    return SystemConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userRole: userRole ?? this.userRole,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      messages: messages ?? this.messages,
      unreadByAdmin: unreadByAdmin ?? this.unreadByAdmin,
      unreadByUser: unreadByUser ?? this.unreadByUser,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      topic: topic ?? this.topic,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'userPhone': userPhone,
    'userRole': userRole,
    'userAvatarUrl': userAvatarUrl,
    'messages': messages.map((m) => m.toMap()).toList(),
    'unreadByAdmin': unreadByAdmin,
    'unreadByUser': unreadByUser,
    'lastMessage': lastMessage,
    'updatedAt': updatedAt.toIso8601String(),
    'status': status,
    'topic': topic,
  };

  factory SystemConversation.fromMap(Map<String, dynamic> map) => SystemConversation(
    id: map['id']?.toString() ?? '',
    userId: map['userId']?.toString() ?? '',
    userName: map['userName']?.toString() ?? '',
    userEmail: map['userEmail']?.toString() ?? '',
    userPhone: map['userPhone']?.toString() ?? '',
    userRole: map['userRole']?.toString() ?? 'Customer',
    userAvatarUrl: map['userAvatarUrl']?.toString(),
    messages: (map['messages'] as List<dynamic>?)
            ?.map((e) => SystemChatMessage.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [],
    unreadByAdmin: (map['unreadByAdmin'] as num?)?.toInt() ?? 0,
    unreadByUser: (map['unreadByUser'] as num?)?.toInt() ?? 0,
    lastMessage: map['lastMessage']?.toString() ?? '',
    updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    status: map['status']?.toString() ?? 'waiting',
    topic: map['topic']?.toString() ?? 'Hỗ trợ chung',
  );
}


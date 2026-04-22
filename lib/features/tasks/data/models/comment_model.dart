class Comment {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final List<String> attachments;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.attachments = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      text: json['text'] ?? '',
      userId: json['userId'] ?? json['user']['_id'] ?? '',
      userName: json['user']?['name'] ?? json['userName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      attachments: (json['attachments'] as List? ?? []).map((a) => a.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
    };
  }
}
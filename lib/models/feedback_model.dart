class FeedbackModel {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  // Convert model to Map for storing in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create model from Map when reading from database
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
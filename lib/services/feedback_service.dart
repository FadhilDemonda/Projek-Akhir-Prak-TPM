import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  static const String _feedbackKey = 'user_feedback';
  final _uuid = Uuid();
  
  // Save feedback to local storage
  Future<bool> saveFeedback(String userId, String content) async {
    try {
      // Create a new feedback model
      final feedback = FeedbackModel(
        id: _uuid.v4(),
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
      );
      
      // Get existing feedback list
      final feedbackList = await getAllFeedback();
      feedbackList.add(feedback);
      
      // Store the updated list
      final prefs = await SharedPreferences.getInstance();
      final feedbackJsonList = feedbackList.map((f) => jsonEncode(f.toMap())).toList();
      await prefs.setStringList(_feedbackKey, feedbackJsonList);
      
      return true;
    } catch (e) {
      print('Save feedback error: $e');
      return false;
    }
  }
  
  // Get all feedback from local storage
  Future<List<FeedbackModel>> getAllFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackJsonList = prefs.getStringList(_feedbackKey) ?? [];
      
      return feedbackJsonList
          .map((jsonStr) => FeedbackModel.fromMap(jsonDecode(jsonStr)))
          .toList();
    } catch (e) {
      print('Get feedback error: $e');
      return [];
    }
  }
  
  // Get feedback for a specific user
  Future<List<FeedbackModel>> getUserFeedback(String userId) async {
    final allFeedback = await getAllFeedback();
    return allFeedback.where((feedback) => feedback.userId == userId).toList();
  }
}
class DiscoveryQuestion {
  final String question;
  final List<String> options;

  DiscoveryQuestion({required this.question, required this.options});

  factory DiscoveryQuestion.fromJson(Map<String, dynamic> json) {
    return DiscoveryQuestion(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((option) => option.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'options': options};
  }
}

class DiscoveryQuestionsResponse {
  final bool success;
  final String status;
  final String message;
  final List<DiscoveryQuestion> questions;
  final int count;

  DiscoveryQuestionsResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.questions,
    required this.count,
  });

  factory DiscoveryQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryQuestionsResponse(
      success: json['success'] as bool,
      status: json['status'] as String,
      message: json['message'] as String,
      questions: (json['data'] as List<dynamic>)
          .map((q) => DiscoveryQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'message': message,
      'data': questions.map((q) => q.toJson()).toList(),
      'count': count,
    };
  }
}

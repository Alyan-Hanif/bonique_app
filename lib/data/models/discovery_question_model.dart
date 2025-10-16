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
  final List<DiscoveryQuestion> questions;

  DiscoveryQuestionsResponse({required this.questions});

  factory DiscoveryQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryQuestionsResponse(
      questions: (json['questions'] as List<dynamic>)
          .map((q) => DiscoveryQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'questions': questions.map((q) => q.toJson()).toList()};
  }
}

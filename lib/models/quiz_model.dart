class QuizQuestion {
  final int id;
  final String question;
  final List<QuizOption> options;

  QuizQuestion({required this.id, required this.question, required this.options});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var list = json['options'] as List;
    List<QuizOption> optionsList = list.map((i) => QuizOption.fromJson(i)).toList();
    return QuizQuestion(
      id: int.parse(json['id_question'].toString()),
      question: json['question_text'],
      options: optionsList,
    );
  }
}

class QuizOption {
  final int id;
  final String text;
  final bool isCorrect;

  QuizOption({required this.id, required this.text, required this.isCorrect});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: int.parse(json['id_option'].toString()),
      text: json['option_text'],
      isCorrect: json['is_correct'] == "1" || json['is_correct'] == 1,
    );
  }
}
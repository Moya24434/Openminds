import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizOption {
  TextEditingController textController = TextEditingController();
}

class QuizQuestion {
  TextEditingController textController = TextEditingController();
  List<QuizOption> options = [];
  int correctOptionIndex = 0;
}

class EditQuizPage extends StatefulWidget {
  final int formationId;
  final List<dynamic> existingQuestions;

  const EditQuizPage({super.key, required this.formationId, required this.existingQuestions});

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  // PRÉ-REMPLIR LE FORMULAIRE AVEC LES ANCIENNES QUESTIONS
  void _loadExistingData() {
    for (var q in widget.existingQuestions) {
      QuizQuestion newQ = QuizQuestion();
      newQ.textController.text = q['question_text'] ?? '';

      List<dynamic> opts = q['options'] ?? [];
      for (int i = 0; i < opts.length; i++) {
        QuizOption newOpt = QuizOption();
        newOpt.textController.text = opts[i]['option_text'] ?? '';
        newQ.options.add(newOpt);

        if (opts[i]['is_correct'] == 1 || opts[i]['is_correct'] == "1") {
          newQ.correctOptionIndex = i;
        }
      }
      _questions.add(newQ);
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    List<Map<String, dynamic>> questionsData = _questions.map((q) {
      List<Map<String, dynamic>> optionsData = [];
      for (int i = 0; i < q.options.length; i++) {
        optionsData.add({
          "option_text": q.options[i].textController.text,
          "is_correct": (i == q.correctOptionIndex)
        });
      }
      return {
        "question_text": q.textController.text,
        "options": optionsData
      };
    }).toList();

    Map<String, dynamic> payload = {
      "id_formation": widget.formationId,
      "questions": questionsData
    };

    try {
      // ⚠️ ATTENTION : Vérifie l'URL
      final url = Uri.parse("http://10.0.2.2/openminds_api/update_quiz_formation.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      final result = json.decode(response.body);
      setState(() => _isLoading = false);

      if (result['status'] == 'success' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Quiz mis à jour avec succès !"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Retour à la page précédente
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        title: const Text("Modifier le QCM", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, qIndex) {
                  final question = _questions[qIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade300)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Question ${qIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                              if (_questions.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setState(() => _questions.removeAt(qIndex)),
                                )
                            ],
                          ),
                          TextFormField(
                            controller: question.textController,
                            validator: (val) => val!.isEmpty ? "Requis" : null,
                          ),
                          const SizedBox(height: 15),
                          ...List.generate(question.options.length, (optIndex) {
                            return Row(
                              children: [
                                Radio<int>(
                                  value: optIndex,
                                  groupValue: question.correctOptionIndex,
                                  activeColor: Colors.green,
                                  onChanged: (val) => setState(() => question.correctOptionIndex = val!),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: question.options[optIndex].textController,
                                    validator: (val) => val!.isEmpty ? "Requis" : null,
                                  ),
                                ),
                                if (question.options.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    onPressed: () => setState(() {
                                      question.options.removeAt(optIndex);
                                      if (question.correctOptionIndex >= question.options.length) {
                                        question.correctOptionIndex = 0;
                                      }
                                    }),
                                  )
                              ],
                            );
                          }),
                          TextButton.icon(
                            onPressed: () => setState(() => question.options.add(QuizOption())),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Ajouter une option"),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    QuizQuestion newQ = QuizQuestion();
                    newQ.options.addAll([QuizOption(), QuizOption()]); // 2 options par défaut
                    _questions.add(newQ);
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("NOUVELLE QUESTION"),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _isLoading ? null : _updateQuiz,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("METTRE À JOUR LE QCM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
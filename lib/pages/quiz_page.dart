import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quiz_model.dart';

class QuizPage extends StatefulWidget {
  final int idFormation;
  final String titreFormation;

  const QuizPage({super.key, required this.idFormation, required this.titreFormation});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      // Utilisation de l'IP de l'émulateur Android (10.0.2.2)
      final response = await http.get(Uri.parse("http://10.0.2.2/openminds_api/get_quiz.php?id_formation=${widget.idFormation}"));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            _questions = jsonResponse.map((data) => QuizQuestion.fromJson(data)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur chargement quiz: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _answerQuestion(bool isCorrect) {
    if (isCorrect) _score++;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // C'est la dernière question !
      _envoiScoreServeur();
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Quiz Terminé ! 🏆", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 60),
            const SizedBox(height: 20),
            Text(
              "Ton score est de $_score / ${_questions.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              (_score / _questions.length) >= 0.7
                  ? "Félicitations, tu as validé cette formation !"
                  : "Dommage, n'hésite pas à relire le cours et recommencer.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Ferme le dialogue
                Navigator.pop(context); // Retour à l'accueil
              },
              child: const Text("Retour à l'accueil", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF004AAD))),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.titreFormation)),
        body: const Center(child: Text("Aucune question trouvée pour ce quiz.")),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    // On limite à 4 options maximum pour garder le design 2x2 propre
    final options = currentQuestion.options.take(4).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.titreFormation, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004AAD),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF004AAD),
              ),
            ),
            const SizedBox(height: 40),

            // Compteur de questions
            Text(
              "QUESTION ${_currentIndex + 1} SUR ${_questions.length}",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),

            // Texte de la question
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Grille de réponses 2x2
            Expanded(
              child: GridView.builder(
                // La clé force Flutter à reconstruire la grille à chaque nouvelle question
                key: ValueKey(_currentIndex),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return _buildChoiceCard(options[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(QuizOption opt) {
    return GestureDetector(
      onTap: () => _answerQuestion(opt.isCorrect),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.lightbulb_circle_outlined,
                color: const Color(0xFF004AAD).withOpacity(0.3),
                size: 40
            ),
            const SizedBox(height: 12),
            Text(
              opt.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _envoiScoreServeur() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id_user');

      if (userId == null) return;

      final response = await http.post(
        Uri.parse("http://10.0.2.2/openminds_api/save_quiz_result.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": userId,
          "id_formation": widget.idFormation,
          "score": _score,
          "total": _questions.length,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("Score enregistré avec succès !");
      }
    } catch (e) {
      debugPrint("Erreur lors de l'envoi du score : $e");
    }
  }

}
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/user_prefs.dart';

// --- CLASSES POUR GÉRER LE QCM ---
class QuizOption {
  TextEditingController textController = TextEditingController();
}

class QuizQuestion {
  TextEditingController textController = TextEditingController();
  List<QuizOption> options = [QuizOption(), QuizOption()]; // 2 options par défaut
  int correctOptionIndex = 0; // Par défaut, la première option est la bonne
}

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // Variables pour la formation
  int? _selectedFormationId;
  List<dynamic> _formations = [];
  bool _isLoadingFormations = true;

  // Liste des questions du quiz
  final List<QuizQuestion> _questions = [QuizQuestion()];

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  // --- 1. RÉCUPÉRER LES FORMATIONS (AVEC VÉRIFICATION ADMIN) ---
  Future<void> _loadFormations() async {
    try {
      final int? userId = await UserPrefs.getUserId();
      if (userId == null) throw Exception("Utilisateur non connecté");

      // ⚠️ Remplace l'URL par ton adresse exacte
      final url = Uri.parse("http://10.0.2.2/openminds_api/get_formations_admin.php");

      // On utilise POST car ton PHP lit un json_decode(file_get_contents)
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_user": userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _formations = data['formations'];
              _isLoadingFormations = false;
            });
          }
        } else {
          throw Exception(data['message'] ?? "Erreur d'accès admin");
        }
      } else {
        throw Exception("Erreur serveur ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFormations = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur formations : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- 2. ENVOYER LE QUIZ AU PHP ---
  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérification : chaque question doit avoir au moins 2 options remplies
    for (var q in _questions) {
      if (q.textController.text.trim().isEmpty) {
        _showError("Toutes les questions doivent être remplies.");
        return;
      }
      for (var opt in q.options) {
        if (opt.textController.text.trim().isEmpty) {
          _showError("Toutes les options de réponse doivent être remplies.");
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    // Formatage des données EXACTEMENT comme ton create_quiz.php le demande
    List<Map<String, dynamic>> questionsData = _questions.map((q) {
      List<Map<String, dynamic>> optionsData = [];
      for (int i = 0; i < q.options.length; i++) {
        optionsData.add({
          "option_text": q.options[i].textController.text,
          "is_correct": (i == q.correctOptionIndex) // true si c'est la bonne réponse
        });
      }
      return {
        "question_text": q.textController.text,
        "options": optionsData
      };
    }).toList();

    Map<String, dynamic> payload = {
      "id_formation": _selectedFormationId,
      "questions": questionsData
    };

    try {
      // ⚠️ Remplace l'URL par ton adresse exacte
      final url = Uri.parse("http://10.0.2.2/openminds_api/create_quiz.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      final result = json.decode(response.body);

      setState(() => _isLoading = false);

      if (result['status'] == 'success' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Quiz créé avec succès !"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        _showError(result['message'] ?? "Erreur lors de la création");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Erreur de connexion au serveur : $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    for (var q in _questions) {
      q.textController.dispose();
      for (var o in q.options) {
        o.textController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        title: const Text("Créer un QCM", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SÉLECTION DE LA FORMATION ---
              const Text("1. Associer à une formation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _isLoadingFormations
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                value: _selectedFormationId,
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                hint: const Text("Sélectionnez une formation"),
                items: _formations.map((formation) {
                  return DropdownMenuItem<int>(
                    value: int.tryParse(formation['id_formation'].toString()) ?? int.tryParse(formation['id'].toString()),
                    child: Text(formation['nom_formation'] ?? formation['titre'] ?? 'Formation'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedFormationId = val),
                validator: (val) => val == null ? "Veuillez choisir une formation" : null,
              ),
              const SizedBox(height: 30),

              // --- LISTE DES QUESTIONS (QCM) ---
              const Text("2. Rédiger les questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),

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
                            decoration: const InputDecoration(hintText: "Ex: Que signifie PLS ?"),
                          ),
                          const SizedBox(height: 15),
                          const Text("Options de réponse (Cochez la bonne) :", style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 10),

                          // LISTE DES OPTIONS POUR CETTE QUESTION
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
                                    decoration: InputDecoration(
                                      hintText: "Option ${optIndex + 1}",
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                if (question.options.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    onPressed: () => setState(() {
                                      question.options.removeAt(optIndex);
                                      if (question.correctOptionIndex >= question.options.length) {
                                        question.correctOptionIndex = 0; // Réinitialise si on supprime la bonne réponse
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

              // --- BOUTON AJOUTER UNE QUESTION ---
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _questions.add(QuizQuestion())),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("NOUVELLE QUESTION"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF004AAD),
                    side: const BorderSide(color: Color(0xFF004AAD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOUTON VALIDER ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _submitQuiz,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SAUVEGARDER LE QCM", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
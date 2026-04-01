import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/formation_model.dart';
import '../../models/session_model.dart';
import '../../services/admin_service.dart';
import '../../services/user_prefs.dart';
import 'edit_formation_page.dart';
import 'edit_session_page.dart';
import 'create_session_page.dart';
import 'create_quiz_page.dart';
import 'edit_quiz_page.dart'; // <-- J'ai ajouté l'importation de la nouvelle page ici

class AdminFormationDetailsPage extends StatefulWidget {
  final Formation formation;

  const AdminFormationDetailsPage({super.key, required this.formation});

  @override
  State<AdminFormationDetailsPage> createState() => _AdminFormationDetailsPageState();
}

class _AdminFormationDetailsPageState extends State<AdminFormationDetailsPage> {
  final AdminService _adminService = AdminService();
  late Formation _currentFormation;

  bool _isLoadingSessions = true;
  List<Session> _sessions = [];

  bool _isLoadingQuiz = true;
  List<dynamic> _quizQuestions = [];

  int? _adminId;

  @override
  void initState() {
    super.initState();
    _currentFormation = widget.formation;
    _initializeData();
  }

  Future<void> _initializeData() async {
    _adminId = await UserPrefs.getUserId();
    _loadSessions();
    _loadQuiz();
  }

  Future<void> _loadSessions() async {
    if (_adminId == null) return;

    setState(() => _isLoadingSessions = true);

    final allSessions = await _adminService.getAllSessions(_adminId!);
    final relatedSessions = allSessions.where((s) => s.formation?.idFormation == _currentFormation.idFormation).toList();

    if (mounted) {
      setState(() {
        _sessions = relatedSessions;
        _isLoadingSessions = false;
      });
    }
  }

  Future<void> _loadQuiz() async {
    setState(() => _isLoadingQuiz = true);

    try {
      final url = Uri.parse("http://10.0.2.2/openminds_api/get_quiz_formation.php?id_formation=${_currentFormation.idFormation}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _quizQuestions = data['questions'];
              _isLoadingQuiz = false;
            });
          }
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception("Erreur serveur HTTP");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingQuiz = false);
        print("Erreur Quiz: $e");
      }
    }
  }

  Future<void> _deleteQuiz() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le quiz ?"),
        content: const Text("Voulez-vous vraiment supprimer tout le QCM de cette formation ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("http://10.0.2.2/openminds_api/delete_quiz_formation.php?id_formation=${_currentFormation.idFormation}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quiz supprimé avec succès"), backgroundColor: Colors.green));
        _loadQuiz();
      } else {
        throw Exception("Erreur serveur");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red));
    }
  }

  void _editFormation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditFormationPage(formation: _currentFormation)),
    );

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  void _deleteFormation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la formation ?"),
        content: const Text("Cette action est irréversible. Les sessions associées pourront être affectées."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true || _adminId == null) return;

    final success = await _adminService.deleteFormation(_adminId!, _currentFormation.idFormation);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Formation supprimée avec succès"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red));
    }
  }

  void _editSession(Session session) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSessionPage(session: session)),
    );
    if (result == true) {
      _loadSessions();
    }
  }

  void _deleteSession(Session session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la session ?"),
        content: const Text("Voulez-vous vraiment supprimer cette session ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true || _adminId == null) return;

    final success = await _adminService.deleteSession(_adminId!, session.idSession);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session supprimée avec succès"), backgroundColor: Colors.green));
      _loadSessions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Détails Formation", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        elevation: 0,
        actions: [
          IconButton(onPressed: _editFormation, icon: const Icon(Icons.edit)),
          IconButton(onPressed: _deleteFormation, icon: const Icon(Icons.delete, color: Colors.red)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentFormation.thematique != null && _currentFormation.thematique!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF004AAD).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(_currentFormation.thematique ?? '', style: const TextStyle(color: Color(0xFF004AAD), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    _currentFormation.titre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  const Text("Description complète", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    _currentFormation.description,
                    style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sessions planifiées", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSessionPage(preselectedFormation: _currentFormation)));
                    _loadSessions();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Ajouter"),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF004AAD)),
                ),
              ],
            ),
            const SizedBox(height: 15),

            if (_isLoadingSessions)
              const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
            else if (_sessions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[300]!)),
                child: const Column(
                  children: [
                    Icon(Icons.event_busy, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Aucune session planifiée pour cette formation.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(session.dateDebut.toString().substring(0, 16), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(session.typeSession == 'Présentiel' ? Icons.location_on : Icons.laptop_chromebook, size: 14, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Expanded(child: Text("${session.typeSession} - ${session.adresse}", style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _editSession(session),
                              icon: const Icon(Icons.edit, color: Color(0xFF004AAD)),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                            ),
                            IconButton(
                              onPressed: () => _deleteSession(session),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quiz d'évaluation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                if (_quizQuestions.isEmpty && !_isLoadingQuiz)
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateQuizPage()));
                      _loadQuiz();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Créer QCM"),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF004AAD)),
                  )
                else if (_quizQuestions.isNotEmpty && !_isLoadingQuiz)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF004AAD)),
                        onPressed: () async {
                          // <-- C'EST ICI QUE TOUT SE PASSE !
                          // On navigue vers EditQuizPage et on lui passe les questions existantes
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditQuizPage(
                                formationId: _currentFormation.idFormation,
                                existingQuestions: _quizQuestions,
                              ),
                            ),
                          );
                          _loadQuiz(); // On recharge les questions quand on revient
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteQuiz,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 15),

            if (_isLoadingQuiz)
              const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
            else if (_quizQuestions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[300]!)),
                child: const Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Aucun quiz associé à cette formation.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _quizQuestions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final question = _quizQuestions[index];
                  final List<dynamic> options = question['options'] ?? [];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF004AAD).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Q${index + 1}: ${question['question_text']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        ...options.map((opt) {
                          bool isCorrect = (opt['is_correct'] == 1 || opt['is_correct'] == "1");
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isCorrect ? Colors.green : Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    opt['option_text'] ?? '',
                                    style: TextStyle(
                                      color: isCorrect ? Colors.green.shade700 : Colors.black87,
                                      fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
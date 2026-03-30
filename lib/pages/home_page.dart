import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_service.dart';
import '../models/session_model.dart';
import 'quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String prenom = "";
  Future<List<Session>> _mySessions = Future.value([]);
  bool _isLoading = true;

  // On va stocker ici les IDs des formations déjà validées
  List<int> _validatedFormationIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- CHARGEMENT DES DONNÉES ---
  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id_user');
    String savedPrenom = prefs.getString('prenom') ?? "Bénévole";

    if (userId != null && userId > 0) {
      // 1. On récupère les IDs des quiz déjà réussis
      await _getValidatedQuizzes(userId);

      // 2. On charge les sessions
      if (mounted) {
        setState(() {
          prenom = savedPrenom;
          _mySessions = SessionService().getUserSessions(userId);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Nouvelle fonction pour récupérer tous les quiz réussis de l'utilisateur
  Future<void> _getValidatedQuizzes(int userId) async {
    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2/openminds_api/get_user_history.php?id_user=$userId")
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        // On extrait juste les IDs des formations validées
        _validatedFormationIds = data.map((item) => int.parse(item['id_formation'].toString())).toList();
      }
    } catch (e) {
      debugPrint("Erreur check validés: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Vos évaluations à valider",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),

                  FutureBuilder<List<Session>>(
                    future: _mySessions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)));
                      }

                      if (snapshot.hasError) return _buildEmptyState("Erreur de chargement.");

                      // Filtrage : On ne garde que les sessions dont la formation n'est PAS dans la liste des validées
                      final sessionsAFiltrer = snapshot.data ?? [];
                      final sessionsAfffichees = sessionsAFiltrer.where((s) =>
                      !_validatedFormationIds.contains(s.formation?.idFormation)
                      ).toList();

                      if (sessionsAfffichees.isEmpty) {
                        return _buildEmptyState("Toutes vos évaluations sont à jour ! 🎉");
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessionsAfffichees.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          return _buildQuizCard(sessionsAfffichees[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE DESIGN ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 25, right: 25, top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bonjour, $prenom 👋", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
          const SizedBox(height: 8),
          const Text("Bienvenue dans votre espace OpenMinds.", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Session session) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF004AAD).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.school_rounded, color: Color(0xFF004AAD), size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.formation?.titre ?? "Formation", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("Évaluation disponible", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    idFormation: session.formation!.idFormation,
                    titreFormation: session.formation!.titre,
                  ),
                ),
              ).then((_) => _loadData()); // Rafraîchit la liste au retour du quiz
            },
            child: const Text("Quiz", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Icon(Icons.assignment_turned_in_rounded, size: 50, color: Colors.green),
          const SizedBox(height: 15),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
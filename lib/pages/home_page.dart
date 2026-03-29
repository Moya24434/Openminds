import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Imagines que tu crées cette page Quiz après
// import 'quiz_page.dart';
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
  // CORRECTION CLÉ : On initialise le Future immédiatement pour éviter le flash rouge.
  // Future.value([]) crée un Future qui contient une liste vide instantanément.
  Future<List<Session>> _mySessions = Future.value([]);
  bool _isLoading = true;

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

    if (mounted) {
      setState(() {
        prenom = savedPrenom;
        // On ne lance la vraie requête que si on a un ID
        if (userId != null && userId > 0) {
          _mySessions = SessionService().getUserSessions(userId);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Style commun : Fond légèrement gris
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. EN-TÊTE MODERNE (Style SearchPage) ---
            _buildHeader(),

            const SizedBox(height: 30),

            // --- 2. SECTION QUIZ À FAIRE ---
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
                      // Pendant le chargement réel (après le initState)
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)));
                      }

                      // Si erreur ou pas de données
                      if (snapshot.hasError) {
                        return _buildEmptyState("Impossible de charger vos quiz.");
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState("Inscrivez-vous à une formation pour commencer !");
                      }

                      // Si tout est OK : La liste stylisée
                      return ListView.separated(
                        shrinkWrap: true, // Important dans un SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // Laisse le scroll au parent
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          return _buildQuizCard(snapshot.data![index]);
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

  // L'en-tête stylisée
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 25, right: 25, top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bonjour, $prenom 👋",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF004AAD)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Bienvenue dans votre espace OpenMinds.\nPrêt à valider de nouvelles compétences ?",
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  // La carte de quiz stylisée (Style ProfilePage stats)
  Widget _buildQuizCard(Session session) {
    String dateAffichee = "${session.dateSession.day}/${session.dateSession.month}/${session.dateSession.year}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // Icône de formation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFF004AAD), size: 26),
          ),
          const SizedBox(width: 18),
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formation?.titre ?? "Formation",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Session terminée le $dateAffichee",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Bouton d'action
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            // N'oublie pas l'import en haut : import 'quiz_page.dart';

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    idFormation: session.formation!.idFormation, // On passe l'ID de la formation
                    titreFormation: session.formation!.titre, // Et le titre
                  ),
                ),
              );
            },
            child: const Text("Quiz", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // État vide stylisé
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
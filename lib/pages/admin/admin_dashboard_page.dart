import 'package:flutter/material.dart';
import 'admin_formations_page.dart';
import 'create_session_page.dart';
import 'admin_stats_page.dart';
import 'admin_users_list_page.dart';
import 'create_quiz_page.dart'; // <-- 1. J'ai ajouté l'import de ta page Quiz

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Tableau de Bord Admin",
          style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Espace Administrateur",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004AAD),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gérez le catalogue de formations et suivez les statistiques du programme.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  // --- US15 : Formations ---
                  _buildAdminCard(
                    context,
                    Icons.library_books,
                    "Formations",
                    "Créer et gérer le catalogue",
                    Colors.orange,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminFormationsPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- UTILISATEURS ---
                  _buildAdminCard(
                    context,
                    Icons.people_alt_rounded,
                    "Utilisateurs",
                    "Gérer les membres et comptes bénévoles",
                    Colors.blue,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUsersListPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- US15 : Sessions ---
                  _buildAdminCard(
                    context,
                    Icons.event,
                    "Sessions",
                    "Planifier des dates de session",
                    Colors.green,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateSessionPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- QUIZ (NOUVEAU) ---
                  _buildAdminCard(
                    context,
                    Icons.quiz, // L'icône pour le quiz
                    "Quiz",
                    "Créer et évaluer les connaissances",
                    Colors.teal, // J'ai choisi bleu canard, mais tu peux mettre Colors.red si tu préfères !
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateQuizPage(), // <-- 2. Lien vers ta page
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- US17 : Statistiques ---
                  _buildAdminCard(
                    context,
                    Icons.bar_chart_rounded,
                    "Statistiques",
                    "Participation, progression, réussite",
                    Colors.purple,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminStatsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing:
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/user_prefs.dart';
import '../models/session_model.dart';
import 'info_formation_page.dart';

class MySessionsPage extends StatelessWidget {
  const MySessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Un fond légèrement gris pour faire ressortir les cartes blanches
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        title: const Text(
          "Mes Formations À Venir",
          style: TextStyle(
            color: Color(0xFF004AAD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // 1. On récupère d'abord l'ID de l'utilisateur
      body: FutureBuilder<int?>(
        future: UserPrefs.getUserId(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData) {
            return const Center(child: Text("Erreur : Utilisateur non connecté"));
          }

          // 2. On récupère les sessions de cet utilisateur
          return FutureBuilder<List<Session>>(
            future: SessionService().getUserSessions(userSnapshot.data!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Vous n'avez pas encore d'inscriptions à venir.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              // 3. On affiche la belle liste
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildFormationCard(context, snapshot.data![index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Le widget qui reproduit exactement ta maquette !
  Widget _buildFormationCard(BuildContext context, Session session) {
    String dateAffichee = "${session.dateDebut.day}/${session.dateDebut.month}/${session.dateDebut.year}";

    return Container(
      padding: const EdgeInsets.all(10), // Même padding que SearchPage
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)) // Ombre plus légère
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE IDENTIQUE À SEARCH_PAGE ---
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              session.formation?.imageUrl ?? 'https://via.placeholder.com/150x100?text=Image',
              width: 120, // Valeur de SearchPage
              height: 100, // Valeur de SearchPage
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120, height: 100, color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // --- TEXTES ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formation?.titre ?? "Formation",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004AAD)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // Ajout de l'icône de lieu pour le réalisme
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.adresse,
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),
                Text("Le $dateAffichee", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),

                const SizedBox(height: 5),
                Text(
                  session.formation?.description ?? "",
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // --- BOUTON ALIGNÉ ---
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InfoFormationPage(session: session)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Plus d'infos", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
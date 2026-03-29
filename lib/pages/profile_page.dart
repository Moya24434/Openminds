import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_session_page.dart'; // Vérifie que le chemin est bon
import '../services/session_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String prenom = "Chargement...";
  int upcomingCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // --- CHARGEMENT DES DONNÉES DYNAMIQUES ---
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id_user');
    String? savedPrenom = prefs.getString('prenom');

    int fetchedCount = 0;

    if (userId != null) {
      try {
        // On interroge la base de données pour savoir combien de sessions l'utilisateur a prévu
        var mySessions = await SessionService().getUserSessions(userId);
        fetchedCount = mySessions.length;
      } catch (e) {
        debugPrint("Erreur lors de la récupération des sessions : $e");
      }
    }

    // On met à jour l'interface une fois les données récupérées
    if (mounted) {
      setState(() {
        prenom = savedPrenom ?? "Utilisateur";
        upcomingCount = fetchedCount;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Un fond légèrement gris pour faire ressortir les blocs blancs
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text(
          "Mon Profil",
          style: TextStyle(
            color: Color(0xFF004AAD),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- EN-TÊTE : Photo + Nom (Design centré et moderne) ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF004AAD).withOpacity(0.3), width: 3),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://i.pinimg.com/736x/8b/6e/88/8b6e885cda6d9b015d1bbfa0876c6df9.jpg', // Placeholder Izuku
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      prenom, // Le VRAI prénom de l'utilisateur connecté !
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004AAD),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004AAD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Bénévole",
                        style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- SECTION : Formations ---
              const Text(
                "Mes Statistiques",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Boutons Réalisées et À Venir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatButton(
                    title: "Réalisées",
                    count: "0", // On mettra ça dynamique plus tard si besoin
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      // TODO: Naviguer vers la page de gauche de ta maquette
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildStatButton(
                    title: "À Venir",
                    count: upcomingCount.toString(), // Le VRAI compte !
                    icon: Icons.calendar_month_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MySessionsPage(),
                        ),
                      ).then((_) {
                        // Astuce : Quand on revient sur cette page, on recharge les données
                        // au cas où l'utilisateur se soit désinscrit d'une session !
                        setState(() => isLoading = true);
                        _loadProfileData();
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // --- SECTION : Paramètres ---
              const Text(
                "Paramètres du compte",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Liste des options stylisée
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingTile(Icons.lock_outline, "Sécurité", "Mot De Passe, Adresse E-Mail..."),
                    const Divider(height: 1, indent: 60, endIndent: 20),
                    _buildSettingTile(Icons.notifications_outlined, "Notifications", "Gérer les alertes et rappels"),
                    const Divider(height: 1, indent: 60, endIndent: 20),
                    _buildSettingTile(Icons.help_outline, "Aide & Support", "FAQ, nous contacter"),
                    const Divider(height: 1, indent: 60, endIndent: 20),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () async {
                        // Déconnexion propre
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login'); // Adapte avec ta route de login
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS PERSONNALISÉS ---

  Widget _buildStatButton({required String title, required String count, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF004AAD), Color(0xFF0066FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004AAD).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 28),
              const SizedBox(height: 10),
              Text(
                count,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF004AAD).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF004AAD)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
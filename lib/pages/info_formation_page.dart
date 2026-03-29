import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../services/user_prefs.dart';

class InfoFormationPage extends StatefulWidget {
  // On exige qu'une Session soit passée à cette page quand on l'ouvre
  final Session session;

  const InfoFormationPage({super.key, required this.session});

  @override
  State<InfoFormationPage> createState() => _InfoFormationPageState();
}

class _InfoFormationPageState extends State<InfoFormationPage> {
  bool isRegistered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // Vérifie l'état d'inscription au chargement de la page
  void _checkStatus() async {
    int? userId = await UserPrefs.getUserId();

    if (userId != null) {
      try {
        List<Session> mySessions = await SessionService().getUserSessions(userId);
        setState(() {
          // On vérifie si l'ID de cette session est dans la liste des sessions de l'utilisateur
          isRegistered = mySessions.any((s) => s.idSession == widget.session.idSession);
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  // Action du bouton S'inscrire / Se désinscrire
  void _toggleRegistration() async {
    int? userId = await UserPrefs.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez vous connecter pour vous inscrire.")),
      );
      return;
    }

    setState(() => isLoading = true); // On lance le chargement

    Map<String, dynamic> result;

    if (isRegistered) {
      // Désinscription
      result = await SessionService().desinscrireSession(userId, widget.session.idSession);
    } else {
      // Inscription
      result = await SessionService().inscrireSession(userId, widget.session.idSession);
    }

    // Gestion du succès ou de l'erreur
    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
      );
      // On inverse l'état du bouton
      setState(() {
        isRegistered = !isRegistered;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Erreur"), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatage de la date de la session
    String dateAffichee = "${widget.session.dateSession.day}/${widget.session.dateSession.month}/${widget.session.dateSession.year}";

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
            "Détails de la formation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGE ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.session.formation?.imageUrl ?? 'https://via.placeholder.com/400x200?text=Pas+d+image',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TITRE ---
                  Text(
                    widget.session.formation?.titre ?? "Formation inconnue",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004AAD),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- ADRESSE ---
                  Text(
                    widget.session.adresse,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  // --- DATES ---
                  Text(
                    "Le $dateAffichee",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // --- DESCRIPTION ---
                  Text(
                    widget.session.formation?.description ?? "Aucune description.",
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 15),

                  // --- INFOS COMPLÉMENTAIRES ---
                  Text(
                    "Thématique : ${widget.session.formation?.thematique ?? 'Non précisée'}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Type : ${widget.session.typeSession}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // --- BOUTON DYNAMIQUE ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // Devient rouge si on est déjà inscrit, sinon reste bleu
                        backgroundColor: isRegistered ? Colors.red[400] : const Color(0xFF004AAD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: isLoading ? null : _toggleRegistration,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        isRegistered ? "SE DÉSINSCRIRE" : "JE M'INSCRIS !",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
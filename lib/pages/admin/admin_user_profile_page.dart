import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../services/session_service.dart';
import '../../services/user_prefs.dart';

class AdminUserProfilePage extends StatefulWidget {
  final UserModel user;

  const AdminUserProfilePage({super.key, required this.user});

  @override
  State<AdminUserProfilePage> createState() => _AdminUserProfilePageState();
}

class _AdminUserProfilePageState extends State<AdminUserProfilePage> {
  final AdminService _adminService = AdminService();
  final SessionService _sessionService = SessionService();
  int? _adminId;
  int _sessionsInscrites = 0;
  int _formationsValidees = 0;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _adminId = await UserPrefs.getUserId();
    
    // Récupère à la fois l'historique (quiz) et les inscriptions (à venir)
    try {
      final history = await _sessionService.getUserHistory(widget.user.id);
      final sessions = await _sessionService.getUserSessions(widget.user.id);
      
      if (mounted) {
        setState(() {
          _formationsValidees = history.length;
          _sessionsInscrites = sessions.length;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'utilisateur ?"),
        content: Text("Voulez-vous vraiment supprimer le compte de ${widget.user.prenom} ${widget.user.nom} ? Cette action est irréversible et retirera toutes ses inscriptions."),
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

    final success = await _adminService.deleteUser(_adminId!, widget.user.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur supprimé avec succès"), backgroundColor: Colors.green));
      Navigator.pop(context, true); // true to refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Profil Utilisateur", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Carte Avatar Profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF004AAD).withOpacity(0.1),
                    backgroundImage: (widget.user.imageUrl != null && widget.user.imageUrl!.isNotEmpty)
                        ? NetworkImage(widget.user.imageUrl!)
                        : null,
                    child: (widget.user.imageUrl == null || widget.user.imageUrl!.isEmpty)
                        ? Text(
                            widget.user.prenom.isNotEmpty ? widget.user.prenom[0].toUpperCase() : "?",
                            style: const TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold, fontSize: 40),
                          )
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text("${widget.user.prenom} ${widget.user.nom}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.user.role, style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informations Détaillées
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                  const SizedBox(height: 20),
                  
                  // Email
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.grey, size: 20),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email (si consenti)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.user.email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30, color: Colors.black12),
                  
                  // Ville (si dispo)
                  Row(
                    children: [
                      const Icon(Icons.location_city, color: Colors.grey, size: 20),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ville", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.user.ville ?? "Non spécifié", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30, color: Colors.black12),
                  
                  // --- Double métrique : Inscriptions & Validations ---
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.school_outlined, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Sessions en cours", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                _isLoadingHistory 
                                  ? const SizedBox(height:15, width: 15, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text("$_sessionsInscrites", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Formations validées", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                _isLoadingHistory 
                                  ? const SizedBox(height:15, width: 15, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text("$_formationsValidees", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Bouton Supprimer
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _deleteUser,
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text("SUPPRIMER CE COMPTE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

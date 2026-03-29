import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'my_session_page.dart';
import '../services/session_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String apiBaseUrl = "http://10.0.2.2/openminds_api"; // Adresse émulateur

  String prenom = "Chargement...";
  String imageUrl = "";
  int upcomingCount = 0;
  bool isLoading = true;
  bool _isPickingImage = false; // Verrou pour l'image picker

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id_user');

    String savedPrenom = prefs.getString('prenom') ?? "Utilisateur";
    String savedImage = prefs.getString('image_url') ?? '';

    int fetchedCount = 0;
    if (userId != null) {
      try {
        var mySessions = await SessionService().getUserSessions(userId);
        fetchedCount = mySessions.length;
      } catch (e) {
        debugPrint("Erreur sessions: $e");
      }
    }

    if (mounted) {
      setState(() {
        prenom = savedPrenom;
        imageUrl = savedImage;
        upcomingCount = fetchedCount;
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40, // Compression pour éviter les lourdeurs PHP
      );

      if (pickedFile != null) {
        setModalState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } finally {
      _isPickingImage = false;
    }
  }

  void _showEditDialog() {
    final TextEditingController nameController = TextEditingController(text: prenom);
    _selectedImage = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Modifier mon profil", style: TextStyle(color: Color(0xFF004AAD))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(setModalState),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        // Logique d'affichage d'image sécurisée
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null) as ImageProvider?,
                        child: (_selectedImage == null && imageUrl.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Cliquez pour changer la photo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Prénom",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD)),
                  onPressed: () => _updateProfile(nameController.text),
                  child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  Future<void> _updateProfile(String nouveauPrenom) async {
    print("--- DÉBUT DE LA MISE À JOUR ---");
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id_user');
      print("ID Utilisateur récupéré : $userId"); // TRACE 1

      if (userId == null) {
        print("ERREUR : ID User est NULL !");
        setState(() => isLoading = false);
        return;
      }

      String base64Image = "";
      if (_selectedImage != null) {
        print("Image détectée, conversion en Base64..."); // TRACE 2
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
        print("Conversion terminée (Taille : ${base64Image.length} caractères)");
      }

      print("Envoi de la requête à l'URL : $apiBaseUrl/update_profile.php"); // TRACE 3

      final response = await http.post(
        Uri.parse("$apiBaseUrl/update_profile.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": userId,
          "prenom": nouveauPrenom,
          "image_64": base64Image,
        }),
      ).timeout(const Duration(seconds: 15));

      print("--- RÉPONSE REÇUE ---"); // TRACE 4
      print("Statut : ${response.statusCode}");
      print("Corps : ${response.body}");

      if (response.body.startsWith('<')) {
        throw "Le serveur a renvoyé du HTML (Erreur PHP probable).";
      }

      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        print("SUCCÈS : Mise à jour BDD OK");
        await prefs.setString('prenom', nouveauPrenom);
        if (result['new_url'] != null && result['new_url'] != "") {
          await prefs.setString('image_url', result['new_url']);
        }
        Navigator.pop(context); // On ferme le modal seulement si ça marche
        _loadProfileData();
      } else {
        print("ERREUR SERVEUR : ${result['message']}");
        throw result['message'] ?? "Erreur inconnue";
      }
    } catch (e) {
      print("CATCH ERREUR : $e"); // TRACE FINALE
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text("Mon Profil", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
          : RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF004AAD).withOpacity(0.3), width: 3)
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showEditDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF004AAD), shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(prenom, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                const SizedBox(height: 35),
                Row(
                  children: [
                    _buildStatButton(title: "Réalisées", count: "3", icon: Icons.check_circle_outline, onTap: () {}),
                    const SizedBox(width: 15),
                    _buildStatButton(
                      title: "À Venir",
                      count: upcomingCount.toString(),
                      icon: Icons.calendar_month_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MySessionsPage())).then((_) => _loadProfileData()),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                _buildSettingsMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]
      ),
      child: Column(
        children: [
          _buildSettingTile(Icons.lock_outline, "Sécurité", "Mot De Passe..."),
          const Divider(height: 1, indent: 60),
          _buildSettingTile(Icons.notifications_outlined, "Notifications", "Gérer les alertes"),
          const Divider(height: 1, indent: 60),
          ListTile(
            leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout, color: Colors.red)
            ),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton({required String title, required String count, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF004AAD), Color(0xFF0066FF)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 28),
              const SizedBox(height: 10),
              Text(count, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
        decoration: BoxDecoration(color: const Color(0xFF004AAD).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF004AAD)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
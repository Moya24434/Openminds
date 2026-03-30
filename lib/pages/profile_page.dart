import 'package:flutter/material.dart';
import 'package:openminds/pages/security_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'my_session_page.dart';
import 'history_page.dart'; // N'oublie pas de créer ce fichier
import '../services/session_service.dart';
import 'login_page.dart';
import 'notfication_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String apiBaseUrl = "http://10.0.2.2/openminds_api";

  String prenom = "Chargement...";
  String imageUrl = "";
  int upcomingCount = 0;
  int completedCount = 0; // CORRECTION : Déclaré ici pour être accessible partout
  bool isLoading = true;
  bool _isPickingImage = false;

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

    int fetchedUpcoming = 0;
    int fetchedHistory = 0;

    if (userId != null) {
      try {
        // Chargement des sessions à venir
        var mySessions = await SessionService().getUserSessions(userId);
        fetchedUpcoming = mySessions.length;

        // Chargement de l'historique (Réalisées)
        var history = await SessionService().getUserHistory(userId);
        fetchedHistory = history.length;
      } catch (e) {
        debugPrint("Erreur lors du chargement des données: $e");
      }
    }

    if (mounted) {
      setState(() {
        prenom = savedPrenom;
        imageUrl = savedImage;
        upcomingCount = fetchedUpcoming;
        completedCount = fetchedHistory;
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
        imageQuality: 40,
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
        },
      ),
    );
  }

  Future<void> _updateProfile(String nouveauPrenom) async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id_user');

      if (userId == null) return;

      String base64Image = "";
      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final response = await http.post(
        Uri.parse("$apiBaseUrl/update_profile.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": userId,
          "prenom": nouveauPrenom,
          "image_64": base64Image,
        }),
      ).timeout(const Duration(seconds: 15));

      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        await prefs.setString('prenom', nouveauPrenom);
        if (result['new_url'] != null && result['new_url'] != "") {
          await prefs.setString('image_url', result['new_url']);
        }
        if (mounted) Navigator.pop(context);
        _loadProfileData();
      } else {
        throw result['message'] ?? "Erreur inconnue";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }

  void _afficherPopupSuppression(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Droit à l'oubli", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _supprimerCompteDefinitivement();
              },
              child: const Text("Oui, supprimer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _supprimerCompteDefinitivement() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id_user');
      if (userId == null) return;

      final response = await http.post(
        Uri.parse("$apiBaseUrl/delete_account.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_user": userId}),
      );

      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
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
                            border: Border.all(color: const Color(0xFF004AAD).withOpacity(0.3), width: 3)),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                          child: imageUrl.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
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
                    _buildStatButton(
                        title: "Réalisées",
                        count: completedCount.toString(),
                        icon: Icons.check_circle_outline,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                        }),
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
      child: Column(
        children: [
          _buildSettingTile(Icons.lock_outline, "Sécurité", "Mot De Passe...", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage()));
          }),
          const Divider(height: 1, indent: 60,endIndent: 20),
          _buildSettingTile(Icons.notifications_outlined, "Notifications", "Gérer les alertes", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsSettingsPage()));
          }),
          const Divider(height: 1, indent: 60,endIndent: 20),
          ListTile(
            leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_forever, color: Colors.red)),
            title: const Text("Supprimer mon compte", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _afficherPopupSuppression(context),
          ),
          const Divider(height: 1, indent: 60,endIndent: 20),
          ListTile(
            leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout, color: Colors.red)),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
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

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap, // On lie l'action ici
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(0xFF004AAD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(icon, color: const Color(0xFF004AAD)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
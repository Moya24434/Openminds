import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _notifFormations = true;
  bool _notifQuiz = true;
  bool _notifRappels = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // On charge les préférences sauvegardées
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifFormations = prefs.getBool('notif_formations') ?? true;
      _notifQuiz = prefs.getBool('notif_quiz') ?? true;
      _notifRappels = prefs.getBool('notif_rappels') ?? false;
    });
  }

  // On sauvegarde le changement
  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'notif_formations') _notifFormations = value;
      if (key == 'notif_quiz') _notifQuiz = value;
      if (key == 'notif_rappels') _notifRappels = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Gestion des alertes", style: TextStyle(color: Color(0xFF004AAD))),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF004AAD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choisissez les notifications que vous souhaitez recevoir sur votre mobile.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            _buildSwitchTile(
              title: "Nouvelles formations",
              subtitle: "Alerte quand une formation est disponible",
              value: _notifFormations,
              onChanged: (val) => _updateSetting('notif_formations', val),
              icon: Icons.school_outlined,
            ),
            const Divider(),
            _buildSwitchTile(
              title: "Résultats des Quiz",
              subtitle: "Confirmation après validation d'un quiz",
              value: _notifQuiz,
              onChanged: (val) => _updateSetting('notif_quiz', val),
              icon: Icons.assignment_turned_in_outlined,
            ),
            const Divider(),
            _buildSwitchTile(
              title: "Rappels de sessions",
              subtitle: "24h avant le début d'une formation",
              value: _notifRappels,
              onChanged: (val) => _updateSetting('notif_rappels', val),
              icon: Icons.alarm,
            ),

            const Spacer(),
            const Center(
              child: Text(
                "OpenMinds respecte votre tranquillité.",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF004AAD).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF004AAD)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      activeColor: const Color(0xFF004AAD),
      value: value,
      onChanged: onChanged,
    );
  }
}
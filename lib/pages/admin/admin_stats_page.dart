import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/session_service.dart';
import '../../services/user_prefs.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  final AdminService _adminService = AdminService();
  final SessionService _sessionService = SessionService();
  bool _isLoading = true;
  String? _errorMessage;

  // Données statistiques dynamiques
  int _totalFormations = 0;
  int _totalSessions = 0;
  int _sessionsEnLigne = 0;
  int _sessionsPresentiel = 0;
  String _topThematique = "N/A";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminId = await UserPrefs.getUserId();
      if (adminId == null) throw Exception("Non connecté");

      // Charger les données via les services existants
      final formations = await _adminService.getAllFormations(adminId);
      final sessions = await _sessionService.getSessions();

      if (!mounted) return;

      // Calcul : Répartition des sessions
      int enLigne = 0;
      int presentiel = 0;
      for (var s in sessions) {
        if (s.typeSession?.toLowerCase().contains("en ligne") == true) {
          enLigne++;
        } else {
          presentiel++;
        }
      }

      // Calcul : Top thématique
      Map<String, int> themesCount = {};
      for (var f in formations) {
        if (f.thematique != null && f.thematique!.trim().isNotEmpty) {
           themesCount[f.thematique!] = (themesCount[f.thematique!] ?? 0) + 1;
        }
      }
      
      String popularTheme = "Aucune";
      int maxCount = 0;
      themesCount.forEach((key, value) {
        if (value > maxCount) {
          maxCount = value;
          popularTheme = key;
        }
      });

      setState(() {
        _totalFormations = formations.length;
        _totalSessions = sessions.length;
        _sessionsEnLigne = enLigne;
        _sessionsPresentiel = presentiel;
        _topThematique = popularTheme;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de charger les statistiques.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        title: const Text(
          "Statistiques",
          style: TextStyle(
            color: Color(0xFF004AAD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF004AAD)),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF004AAD)),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Vue d'ensemble du Catalogue",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004AAD),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Mesurez l'impact du programme de formation.",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 25),

                        // --- KPI Cards (Catalogue) ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildKpiCard(
                                icon: Icons.library_books,
                                label: "Formations",
                                value: _totalFormations.toString(),
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildKpiCard(
                                icon: Icons.event,
                                label: "Sessions actives",
                                value: _totalSessions.toString(),
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- Insights Avancés ---
                        const Text(
                          "Insights",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildInsightRow(
                          icon: Icons.star,
                          color: Colors.amber,
                          title: "Thématique la plus populaire",
                          value: _topThematique,
                          subtitle: "Génère le plus de formations sur le réseau.",
                        ),
                        const SizedBox(height: 15),
                        _buildRatioCard(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRatioCard() {
    int total = _sessionsEnLigne + _sessionsPresentiel;
    double ratioLigne = total == 0 ? 0.5 : _sessionsEnLigne / total;
    double ratioPresentiel = total == 0 ? 0.5 : _sessionsPresentiel / total;

    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.pie_chart, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 15),
              const Text("Répartition des Sessions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: (ratioPresentiel * 100).toInt() <= 0 ? 1 : (ratioPresentiel * 100).toInt(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📍 Présentiel", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 5),
                    Container(height: 10, decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 5),
                    Text("$_sessionsPresentiel", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: (ratioLigne * 100).toInt() <= 0 ? 1 : (ratioLigne * 100).toInt(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("💻 En Ligne", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 5),
                    Container(height: 10, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 5),
                    Text("$_sessionsEnLigne", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({required IconData icon, required Color color, required String title, required String value, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKpiCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 15),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD)),
              child: const Text("Réessayer", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

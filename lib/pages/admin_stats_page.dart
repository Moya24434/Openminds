import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/admin_service.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _errorMessage;

  // Données statistiques
  int _totalBenevoles = 0;
  int _totalFormations = 0;
  int _totalSessions = 0;
  int _totalInscriptions = 0;
  double _tauxReussite = 0.0;
  double _tauxParticipation = 0.0;

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

    final result = await _adminService.getAdminStats();

    if (!mounted) return;

    if (result['status'] == 'success') {
      final data = result['data'];
      setState(() {
        _totalBenevoles = int.tryParse(data['total_benevoles'].toString()) ?? 0;
        _totalFormations = int.tryParse(data['total_formations'].toString()) ?? 0;
        _totalSessions = int.tryParse(data['total_sessions'].toString()) ?? 0;
        _totalInscriptions = int.tryParse(data['total_inscriptions'].toString()) ?? 0;
        _tauxReussite = double.tryParse(data['taux_reussite'].toString()) ?? 0.0;
        _tauxParticipation = double.tryParse(data['taux_participation'].toString()) ?? 0.0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? "Impossible de charger les statistiques";
        _isLoading = false;
      });
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
                "Vue d'ensemble",
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

              // --- KPI Cards (2x2 grid) ---
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      icon: Icons.people,
                      label: "Bénévoles",
                      value: _totalBenevoles.toString(),
                      color: const Color(0xFF004AAD),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildKpiCard(
                      icon: Icons.library_books,
                      label: "Formations",
                      value: _totalFormations.toString(),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      icon: Icons.event,
                      label: "Sessions",
                      value: _totalSessions.toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildKpiCard(
                      icon: Icons.how_to_reg,
                      label: "Inscriptions",
                      value: _totalInscriptions.toString(),
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Taux de réussite ---
              const Text(
                "Performance globale",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildCircularStat(
                      label: "Taux de réussite",
                      subtitle: "aux quiz",
                      percentage: _tauxReussite,
                      color: _tauxReussite >= 70
                          ? Colors.green
                          : _tauxReussite >= 40
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildCircularStat(
                      label: "Participation",
                      subtitle: "aux sessions",
                      percentage: _tauxParticipation,
                      color: _tauxParticipation >= 70
                          ? Colors.green
                          : _tauxParticipation >= 40
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget : Carte KPI ---
  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- Widget : Indicateur circulaire ---
  Widget _buildCircularStat({
    required String label,
    required String subtitle,
    required double percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                percentage: percentage,
                color: color,
                backgroundColor: Colors.grey[200]!,
              ),
              child: Center(
                child: Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- Vue d'erreur ---
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
            const SizedBox(height: 15),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Réessayer",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CustomPainter pour l'indicateur circulaire ---
class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Fond gris
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Arc de progression
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Commence en haut
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

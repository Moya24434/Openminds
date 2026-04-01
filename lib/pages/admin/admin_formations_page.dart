import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/formation_model.dart';
import 'create_formation_page.dart';
import 'create_session_page.dart';
import 'admin_formation_details_page.dart';

class AdminFormationsPage extends StatefulWidget {
  const AdminFormationsPage({super.key});

  @override
  State<AdminFormationsPage> createState() => _AdminFormationsPageState();
}

class _AdminFormationsPageState extends State<AdminFormationsPage> {
  final AdminService _adminService = AdminService();
  late Future<List<Formation>> _formationsFuture;

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  void _loadFormations() {
    _formationsFuture = _adminService.getFormations();
  }

  void _refresh() {
    setState(() {
      _loadFormations();
    });
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
          "Catalogue des Formations",
          style: TextStyle(
            color: Color(0xFF004AAD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateFormationPage(),
            ),
          ).then((_) => _refresh());
        },
        backgroundColor: const Color(0xFF004AAD),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nouvelle Formation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<Formation>>(
          future: _formationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF004AAD)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 15),
                      Text(
                        "Erreur : ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final formations = snapshot.data ?? [];

            if (formations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 15),
                      const Text(
                        "Aucune formation pour l'instant.\nCliquez sur le bouton + pour en créer une !",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: formations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildFormationCard(formations[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormationCard(Formation formation) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminFormationDetailsPage(formation: formation),
          ),
        );
        // Si true est retourné, la formation a été modifiée ou supprimée, on raffraichit
        if (result == true) {
          _refresh();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
          // Image de la formation
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              formation.imageUrl ?? '',
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF004AAD).withOpacity(0.8),
                      const Color(0xFF0066FF).withOpacity(0.6),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white54, size: 50),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thématique (badge)
                if (formation.thematique != null && formation.thematique!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004AAD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formation.thematique ?? '',
                      style: const TextStyle(
                        color: Color(0xFF004AAD),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Titre
                Text(
                  formation.titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  formation.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                // Bouton "Ajouter une session"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateSessionPage(
                            preselectedFormation: formation,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.event_available, size: 18),
                    label: const Text("Ajouter une session"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF004AAD),
                      side: const BorderSide(color: Color(0xFF004AAD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
}

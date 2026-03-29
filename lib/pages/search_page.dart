import 'package:flutter/material.dart';
import 'info_formation_page.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SessionService _sessionService = SessionService();

  // 1. On stocke le Future ici pour ne pas rappeler l'API à chaque lettre tapée !
  late Future<List<Session>> _sessionsFuture;

  // Variables pour la recherche et les filtres
  String _searchQuery = "";
  String? _selectedThematique;
  String? _selectedType; // Présentiel ou En ligne

  @override
  void initState() {
    super.initState();
    // On charge les données une seule fois au démarrage de la page
    _sessionsFuture = _sessionService.getSessions();
  }

  // --- LOGIQUE DE FILTRAGE ---
  List<Session> _getFilteredSessions(List<Session> allSessions) {
    return allSessions.where((session) {
      // 1. Filtre par texte (titre ou adresse)
      final titre = session.formation?.titre.toLowerCase() ?? "";
      final adresse = session.adresse.toLowerCase();
      final recherche = _searchQuery.toLowerCase();
      final matchesSearch = titre.contains(recherche) || adresse.contains(recherche);

      // 2. Filtre par thématique
      final matchesThematique = _selectedThematique == null || session.formation?.thematique == _selectedThematique;

      // 3. Filtre par type (Présentiel / En ligne)
      final matchesType = _selectedType == null || session.typeSession == _selectedType;

      return matchesSearch && matchesThematique && matchesType;
    }).toList();
  }

  // --- MENU DES FILTRES (BOTTOM SHEET) ---
  void _showFilterModal(List<Session> allSessions) {
    // On extrait les thématiques uniques de la liste pour créer les boutons dynamiquement
    final thematiques = allSessions
        .map((s) => s.formation?.thematique)
        .where((t) => t != null && t.isNotEmpty)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder( // Permet de mettre à jour l'intérieur du modal
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filtres", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                    const SizedBox(height: 20),

                    const Text("Type de session", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ["Présentiel", "En ligne"].map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: const Color(0xFF004AAD).withOpacity(0.2),
                          labelStyle: TextStyle(color: isSelected ? const Color(0xFF004AAD) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          onSelected: (selected) {
                            setModalState(() => _selectedType = selected ? type : null);
                            setState(() => _selectedType = selected ? type : null); // Met à jour la liste derrière
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text("Thématique", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: thematiques.map((thematique) {
                        final isSelected = _selectedThematique == thematique;
                        return ChoiceChip(
                          label: Text(thematique!),
                          selected: isSelected,
                          selectedColor: const Color(0xFF004AAD).withOpacity(0.2),
                          labelStyle: TextStyle(color: isSelected ? const Color(0xFF004AAD) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          onSelected: (selected) {
                            setModalState(() => _selectedThematique = selected ? thematique : null);
                            setState(() => _selectedThematique = selected ? thematique : null);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004AAD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Appliquer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond légèrement grisé pour le contraste
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- EN-TÊTE FIXE (Titre + Recherche) ---
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trouver une formation",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF004AAD)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              // Relance le build avec le nouveau mot-clé pour filtrer la liste
                              setState(() => _searchQuery = value);
                            },
                            decoration: const InputDecoration(
                              hintText: "Titre, ville...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              prefixIcon: Icon(Icons.search, color: Color(0xFF004AAD)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Bouton Filtre (avec un petit point rouge s'il y a des filtres actifs)
                      FutureBuilder<List<Session>>(
                          future: _sessionsFuture,
                          builder: (context, snapshot) {
                            bool hasActiveFilters = _selectedThematique != null || _selectedType != null;
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: hasActiveFilters ? const Color(0xFF004AAD) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.tune, color: hasActiveFilters ? Colors.white : const Color(0xFF004AAD)),
                                    onPressed: () {
                                      if (snapshot.hasData) {
                                        _showFilterModal(snapshot.data!);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- LISTE DYNAMIQUE ---
            Expanded(
              child: FutureBuilder<List<Session>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucune formation dans la base."));
                  }

                  // On applique nos filtres locaux sur les données reçues
                  final filteredSessions = _getFilteredSessions(snapshot.data!);

                  if (filteredSessions.isEmpty) {
                    return const Center(
                      child: Text("Aucun résultat pour cette recherche 🕵️‍♂️", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredSessions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15), // Espace plus propre qu'une ligne
                    itemBuilder: (context, index) {
                      return _buildFormationListItem(filteredSessions[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CARTE DE FORMATION (Intacte, comme demandé !) ---
  Widget _buildFormationListItem(Session session) {
    String dateAffichee = "${session.dateSession.day}/${session.dateSession.month}/${session.dateSession.year}";

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              session.formation?.imageUrl ?? 'https://via.placeholder.com/150x100?text=Image',
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formation?.titre ?? "Formation",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AAD),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  session.adresse,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Le $dateAffichee",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  session.formation?.description ?? "Pas de description",
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoFormationPage(session: session),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Plus d'infos",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
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
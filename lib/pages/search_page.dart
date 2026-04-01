import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  // 1. CORRECTION : Plus de mot "late" ! On accepte qu'il soit vide (?) au démarrage.
  Future<List<Session>>? _sessionsFuture;

  // Variables pour la recherche et les filtres
  String _searchQuery = "";
  String? _selectedThematique;
  String? _selectedType;
  double _selectedDistance = 100.0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    Position? position = await _determinePosition();
    if (mounted) {
      setState(() {
        if (position != null) {
          _sessionsFuture = _sessionService.getSessions(
              lat: position.latitude,
              lng: position.longitude
          );
        } else {
          _sessionsFuture = _sessionService.getSessions();
        }
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      return null;
    }
  }

  // --- LOGIQUE DE FILTRAGE LOCAL ---
  List<Session> _getFilteredSessions(List<Session> allSessions) {
    return allSessions.where((session) {
      final titre = session.formation?.titre.toLowerCase() ?? "";
      final adresse = session.adresse.toLowerCase();
      final recherche = _searchQuery.toLowerCase();
      final matchesSearch = titre.contains(recherche) || adresse.contains(recherche);

      final matchesThematique = _selectedThematique == null || session.formation?.thematique == _selectedThematique;

      // 2. CORRECTION : Détection "En ligne" à l'épreuve des balles (espaces, majuscules...)
      final typeLower = session.typeSession.toLowerCase();
      final isOnline = typeLower.contains("ligne") || typeLower.contains("distanciel") || typeLower.contains("visio");

      // Vérifie si le type correspond à ce que l'utilisateur a sélectionné dans le filtre
      final matchesType = _selectedType == null ||
          (_selectedType == "En ligne" ? isOnline : !isOnline);

      // 3. CORRECTION : Le filtre de distance ignore correctement les sessions en ligne
      final matchesDistance = _selectedDistance >= 100 ||
          isOnline ||
          session.distance == null || // <-- AJOUTE ÇA
          session.distance! <= _selectedDistance;

      return matchesSearch && matchesThematique && matchesType && matchesDistance;
    }).toList();
  }

  // --- MENU DES FILTRES (BOTTOM SHEET) ---
  void _showFilterModal(List<Session> allSessions) {
    final thematiques = allSessions
        .map((s) => s.formation?.thematique)
        .where((t) => t != null && t.isNotEmpty)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 20.0,
                    bottom: MediaQuery.of(context).padding.bottom + 20.0
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filtres", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Distance maximale", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            _selectedDistance >= 100 ? "Illimitée" : "${_selectedDistance.toInt()} km",
                            style: const TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    Slider(
                      value: _selectedDistance,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      activeColor: const Color(0xFF004AAD),
                      inactiveColor: const Color(0xFF004AAD).withOpacity(0.2),
                      onChanged: (value) {
                        setModalState(() => _selectedDistance = value);
                        setState(() => _selectedDistance = value);
                      },
                    ),
                    const SizedBox(height: 15),

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
                            setState(() => _selectedType = selected ? type : null);
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const Text("Trouver une formation", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
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

                      _sessionsFuture == null
                          ? const SizedBox(width: 50, height: 50)
                          : FutureBuilder<List<Session>>(
                          future: _sessionsFuture,
                          builder: (context, snapshot) {
                            bool hasActiveFilters = _selectedThematique != null || _selectedType != null || _selectedDistance < 100;
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
                                      if (snapshot.hasData) _showFilterModal(snapshot.data!);
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

            Expanded(
              // 4. CORRECTION : Évite le plantage en attendant le GPS
              child: _sessionsFuture == null
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF004AAD)),
                    SizedBox(height: 15),
                    Text("Recherche de votre position...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : FutureBuilder<List<Session>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)));
                  }
                  if (snapshot.hasError) return Center(child: Text("Erreur : ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucune formation dans la base."));

                  final filteredSessions = _getFilteredSessions(snapshot.data!);

                  if (filteredSessions.isEmpty) {
                    return const Center(child: Text("Aucun résultat pour cette recherche 🕵️‍♂️", style: TextStyle(color: Colors.grey, fontSize: 16)));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredSessions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) => _buildFormationListItem(filteredSessions[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationListItem(Session session) {
      String dateAffichee = "${session.dateDebut.day}/${session.dateDebut.month}/${session.dateDebut.year}";
    final typeLower = session.typeSession.toLowerCase();
    final isOnline = typeLower.contains("ligne") || typeLower.contains("distanciel") || typeLower.contains("visio");

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
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
                width: 120, height: 100, color: Colors.grey[200],
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004AAD)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                if (isOnline)
                  const Row(
                    children: [
                      Icon(Icons.laptop_chromebook, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text("Session en ligne", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.distance != null ? "à ${session.distance!.toStringAsFixed(1)} km" : session.adresse,
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 5),
                Text("Le $dateAffichee", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  session.formation?.description ?? "Pas de description",
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InfoFormationPage(session: session))),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Plus d'infos", style: TextStyle(fontSize: 11, color: Colors.grey)),
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
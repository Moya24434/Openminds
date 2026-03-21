import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../models/session_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionService _sessionService = SessionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        title: const Text("OpenMinds", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: FutureBuilder<List<Session>>(
        future: _sessionService.getSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune formation disponible"));
          }

          final session = snapshot.data![0]; // On affiche la première pour le test

          return Column(
            children: [
              const SizedBox(height: 20),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFormationCard(session),
              )),
              _buildActionButtons(),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFormationCard(Session session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE AVEC TAILLE FIXE POUR ÉVITER L'ERREUR ROUGE
            SizedBox(
              height: 220,
              child: Image.network(
                'https://via.placeholder.com/400x250',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                  const SizedBox(height: 10),
                  Text(session.adresse, style: const TextStyle(fontSize: 16)),
                  Text("Le ${session.date}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text(session.description, style: const TextStyle(color: Colors.grey), maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.thumb_down_alt_outlined, Colors.black54),
          _buildActionButton(Icons.star_border, Colors.blue, isBig: true),
          _buildActionButton(Icons.thumb_up_alt_outlined, Colors.black54),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, {bool isBig = false}) {
    return Container(
      padding: EdgeInsets.all(isBig ? 20 : 15),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: Icon(icon, color: color, size: isBig ? 35 : 30),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), color: Color(0xFF004AAD)),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Pour Moi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Mon Profil'),
        ],
      ),
    );
  }
}
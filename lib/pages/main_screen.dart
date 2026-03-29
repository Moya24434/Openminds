import 'package:flutter/material.dart';
import 'home_page.dart'; // Ta page actuelle modifiée
import 'profile_page.dart'; // Ajoute l'import en haut
import 'search_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // L'index de l'onglet actif (0 = Rechercher, 1 = Pour Moi, 2 = Profil)
  int _selectedIndex = 1; // On démarre sur "Pour Moi" par défaut

  // La liste des pages à afficher en fonction de l'onglet
  final List<Widget> _pages = [
    const SearchPage(), // <--- Remplace le Center() par ta nouvelle page
    const HomePage(),
    const ProfilePage(),
  ];

  // Fonction appelée quand on clique sur un onglet
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le corps change en fonction de l'index sélectionné
      body: _pages[_selectedIndex],

      // La vraie barre de navigation globale
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Color(0xFF004AAD),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: const Color(0xFF004AAD),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            type: BottomNavigationBarType.fixed, // Empêche les icônes de bouger
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Rechercher'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), // Icône pleine quand sélectionné
                  activeIcon: Icon(Icons.favorite),
                  label: 'Pour Moi'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil'
              ),
            ],
          ),
        ),
      ),
    );
  }
}
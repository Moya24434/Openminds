import 'package:flutter/material.dart';
import '../services/formation_service.dart';
import '../models/formation_model.dart';

class FormationsPage extends StatefulWidget {
  const FormationsPage({super.key});

  @override
  State<FormationsPage> createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  final FormationService _service = FormationService();
  late Future<List<Formation>> _formations;

  @override
  void initState() {
    super.initState();
    _formations = _service.getFormations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      body: FutureBuilder<List<Formation>>(
        future: _formations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else {
            final formations = snapshot.data!;
            return ListView.builder(
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                return ListTile(
                  title: Text(formation.titre),
                  subtitle: Text(formation.thematique ?? 'Aucune thématique'),
                  leading: const Icon(Icons.menu_book, color: Color(0xFF004AAD)), // Un petit icône pour faire joli
                );
              },
            );
          }
        },
      ),
    );
  }
}
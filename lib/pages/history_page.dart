import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réussites", style: TextStyle(color: Color(0xFF004AAD))),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF004AAD),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune formation validée pour le moment."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: const Icon(Icons.stars, color: Colors.amber, size: 40),
                  title: Text(item['titre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Validé le : ${item['date_passage']}"),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                    child: Text("${item['score']}%", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id_user') ?? 0;
    return await SessionService().getUserHistory(userId);
  }
}
import 'package:flutter/material.dart';

class PageTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(                          // ← squelette de page
      appBar: AppBar(
        title: Text("Mon titre"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Contenu principal", style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),            // ← espacement
            ElevatedButton(
              onPressed: () {},
              child: Text("Cliquer"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
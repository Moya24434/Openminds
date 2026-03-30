import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Politique de confidentialité", style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF004AAD), // La couleur bleue de ton groupe !
        foregroundColor: Colors.white, // Flèche de retour en blanc
      ),
      // SingleChildScrollView permet de faire défiler le texte si l'écran est petit
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Text(
          "Politique de Confidentialité - OpenMinds\n\n"
              "1. Collecte des données\n"
              "Nous collectons les données suivantes : nom, prénom, email, ville, etc., lors de votre inscription pour pouvoir vous identifier.\n\n"
              "2. Utilisation des données\n"
              "Ces données sont utilisées uniquement pour le fonctionnement de l'application (gestion des sessions, inscriptions aux formations, suivi des quiz).\n\n"
              "3. Protection et Sécurité\n"
              "Vos mots de passe sont cryptés. Vos données sont stockées de manière sécurisée et ne seront jamais vendues à des tiers ni utilisées à des fins publicitaires.\n\n"
              "4. Vos droits (RGPD)\n"
              "Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez d'un droit d'accès, de rectification et de suppression de vos données.\n\n"
              "Vous avez la possibilité de supprimer l'intégralité de votre compte et de vos données directement depuis les paramètres de l'application (Droit à l'oubli).\n\n"
              "Pour toute question, contactez l'équipe OpenMinds.",
          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        ),
      ),
    );
  }
}
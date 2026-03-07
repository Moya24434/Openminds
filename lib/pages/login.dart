import "package:flutter/material.dart";
import "package:flutter/animation.dart";

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Variables d'état
  String monTexte = "Bonjour !";
  int compteur = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(body: Form(
      child: Column( children: [
        SizedBox(
          width: screenWidth * 0.35,   // 70% de la largeur
          height: screenHeight * 0.35, // 70% de la hauteur
          child: Image.asset('assets/images/OpenMindsLogo.png'),
        )

      ],)
    )

    );
  }
}

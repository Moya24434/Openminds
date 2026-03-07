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
    return Scaffold(body: Container(
      child: Form(
        child: Column( children: [

        ],)
      )
    )

    );
  }
}

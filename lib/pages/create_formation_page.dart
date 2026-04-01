import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class CreateFormationPage extends StatefulWidget {
  final int idUser;
  const CreateFormationPage({super.key, required this.idUser});

  @override
  State<CreateFormationPage> createState() => _CreateFormationPageState();
}

class _CreateFormationPageState extends State<CreateFormationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedThematique = 'Secourisme';
  bool _isLoading = false;

  final List<String> _thematiques = [
    'Secourisme',
    'Engagement',
    'Inclusion',
    'Environnement',
    'Numérique',
    'Santé',
    'Autre',
  ];

  Future<void> _submitFormation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final bool result = await AdminService().createFormation(
      widget.idUser,
      _titreController.text.trim(),
      _descriptionController.text.trim(),
      _selectedThematique,
      null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Formation créée avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la création"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        title: const Text(
          "Nouvelle Formation",
          style: TextStyle(
            color: Color(0xFF004AAD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Créer une formation",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Remplissez les informations pour ajouter une nouvelle formation au catalogue.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              _buildLabel("Titre de la formation"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Le titre est obligatoire";
                  }
                  return null;
                },
                decoration: _inputDecoration("Ex: Formation au PSC1"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "La description est obligatoire";
                  }
                  return null;
                },
                decoration: _inputDecoration(
                    "Décrivez le contenu et les objectifs de la formation..."),
              ),
              const SizedBox(height: 20),

              _buildLabel("Thématique"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedThematique,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF004AAD)),
                    items: _thematiques.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedThematique = newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _submitFormation,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "CRÉER LA FORMATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF004AAD), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
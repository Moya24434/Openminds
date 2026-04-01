import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/formation_model.dart';
import '../../services/user_prefs.dart';

class EditFormationPage extends StatefulWidget {
  final Formation formation;

  const EditFormationPage({super.key, required this.formation});

  @override
  State<EditFormationPage> createState() => _EditFormationPageState();
}

class _EditFormationPageState extends State<EditFormationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  String? _selectedThematique;
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

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.formation.titre);
    _descriptionController = TextEditingController(text: widget.formation.description);
    
    // Si la thématique de la base de données existe dans notre liste, on la sélectionne, sinon on prend 'Autre'
    if (widget.formation.thematique != null && _thematiques.contains(widget.formation.thematique)) {
      _selectedThematique = widget.formation.thematique;
    } else {
      _selectedThematique = 'Autre';
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final int? userId = await UserPrefs.getUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : administrateur non identifié"), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await AdminService().updateFormation(
      userId,
      widget.formation.idFormation,
      _titreController.text.trim(),
      _descriptionController.text.trim(),
      _selectedThematique ?? 'Autre',
      widget.formation.imageUrl,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Formation modifiée avec succès"), backgroundColor: Colors.green),
      );
      // Retour à la page précédente en signalant qu'une modification a eu lieu
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la modification"), backgroundColor: Colors.red),
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
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Modifier Formation",
          style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Titre de la formation"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titreController,
                validator: (val) => val == null || val.trim().isEmpty ? "Obligatoire" : null,
                decoration: _inputDecoration("Titre"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                validator: (val) => val == null || val.trim().isEmpty ? "Obligatoire" : null,
                decoration: _inputDecoration("Description détaillée..."),
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
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF004AAD)),
                    items: _thematiques.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedThematique = val),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _submitUpdate,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SAUVEGARDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF004AAD), width: 2)),
    );
  }
}

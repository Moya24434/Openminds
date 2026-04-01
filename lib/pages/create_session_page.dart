import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/formation_model.dart';
import '../../services/admin_service.dart';

class CreateSessionPage extends StatefulWidget {
  final Formation? preselectedFormation;
  final int idUser;

  const CreateSessionPage({super.key, this.preselectedFormation, required this.idUser});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _lieuController = TextEditingController();
  final AdminService _adminService = AdminService();

  Formation? _selectedFormation;
  List<Formation> _formations = [];
  String _selectedType = 'Présentiel';
  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;
  bool _isLoading = false;
  bool _isLoadingFormations = true;

  @override
  void initState() {
    super.initState();
    _selectedFormation = widget.preselectedFormation;
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    final formations = await _adminService.getAllFormations(widget.idUser);
    if (mounted) {
      setState(() {
        _formations = formations;
        _isLoadingFormations = false;
      });
    }
  }

  Future<void> _pickDateDebut() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004AAD),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateDebut = picked);
  }

  Future<void> _pickDateFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateDebut ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: _selectedDateDebut ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004AAD),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateFin = picked);
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFormation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une formation"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateDebut == null || _selectedDateFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une date de début et de fin"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String formattedDateDebut = DateFormat('yyyy-MM-dd').format(_selectedDateDebut!);
    final String formattedDateFin = DateFormat('yyyy-MM-dd').format(_selectedDateFin!);

    final bool result = await _adminService.createSession(
      widget.idUser,
      _selectedFormation!.idFormation,
      _selectedType,
      _lieuController.text.trim(),
      formattedDateDebut,
      formattedDateFin,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Session créée avec succès !"),
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
    _lieuController.dispose();
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
          "Nouvelle Session",
          style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoadingFormations
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Planifier une session",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004AAD)),
              ),
              const SizedBox(height: 5),
              const Text(
                "Définissez les détails de la nouvelle session de formation.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // --- Formation associée ---
              _buildLabel("Formation associée"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Formation>(
                    value: _selectedFormation,
                    isExpanded: true,
                    hint: const Text("Sélectionner une formation"),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF004AAD)),
                    items: _formations.map((Formation f) {
                      return DropdownMenuItem<Formation>(
                        value: f,
                        child: Text(f.titre, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (Formation? newValue) {
                      setState(() => _selectedFormation = newValue);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Date de début ---
              _buildLabel("Date de début"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDateDebut,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF004AAD)),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDateDebut != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDateDebut!)
                            : "Choisir une date de début",
                        style: TextStyle(
                          color: _selectedDateDebut != null ? Colors.black87 : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Date de fin ---
              _buildLabel("Date de fin"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDateFin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF004AAD)),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDateFin != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDateFin!)
                            : "Choisir une date de fin",
                        style: TextStyle(
                          color: _selectedDateFin != null ? Colors.black87 : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Type de session ---
              _buildLabel("Type de session"),
              const SizedBox(height: 8),
              Row(
                children: ['Présentiel', 'En ligne'].map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: type == 'Présentiel' ? 5 : 0,
                          left: type == 'En ligne' ? 5 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF004AAD) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF004AAD) : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type == 'Présentiel' ? Icons.location_on : Icons.laptop_chromebook,
                              size: 18,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // --- Lieu ---
              _buildLabel("Lieu / Lien de réunion"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lieuController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Le lieu est obligatoire";
                  }
                  return null;
                },
                decoration: _inputDecoration("Ex: Paris ou Lien Zoom"),
              ),
              const SizedBox(height: 40),

              // --- Bouton Enregistrer ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _submitSession,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "PLANIFIER LA SESSION",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF004AAD), width: 2),
      ),
    );
  }
}
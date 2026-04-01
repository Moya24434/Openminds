import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/formation_model.dart';
import '../../services/admin_service.dart';
import '../../services/user_prefs.dart';
import 'package:geocoding/geocoding.dart';

class CreateSessionPage extends StatefulWidget {
  final Formation? preselectedFormation;

  const CreateSessionPage({super.key, this.preselectedFormation});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _lieuController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final AdminService _adminService = AdminService();

  Formation? _selectedFormation;
  List<Formation> _formations = [];
  String _selectedType = 'Présentiel';
  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;
  TimeOfDay? _selectedTimeDebut;
  TimeOfDay? _selectedTimeFin;
  bool _isLoading = false;
  bool _isLoadingFormations = true;

  @override
  void initState() {
    super.initState();
    _selectedFormation = widget.preselectedFormation;
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    final formationsBrutes = await _adminService.getFormations();
    
    // 1. Filtrer les doublons potentiels renvoyés par l'API (basé sur idFormation)
    final Map<int, Formation> formationsUniques = {};
    for (var f in formationsBrutes) {
      formationsUniques[f.idFormation] = f;
    }
    final formations = formationsUniques.values.toList();

    if (mounted) {
      setState(() {
        _formations = formations;
        
        // 2. Si on a une formation présélectionnée, on s'assure qu'elle pointe 
        // vers la véritable instance présente dans la liste nouvellement téléchargée.
        if (_selectedFormation != null) {
          final found = _formations.where((f) => f.idFormation == _selectedFormation!.idFormation).toList();
          if (found.isNotEmpty) {
            _selectedFormation = found.first;
          } else {
            // Si la formation a été supprimée entre temps, on reset
            _selectedFormation = null; 
          }
        }
        
        _isLoadingFormations = false;
      });
    }
  }

  Future<void> _pickDate({required bool isDebut}) async {
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

    if (picked != null) {
      setState(() {
        if (isDebut) {
          _selectedDateDebut = picked;
        } else {
          _selectedDateFin = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isDebut}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004AAD),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDebut) {
          _selectedTimeDebut = picked;
        } else {
          _selectedTimeFin = picked;
        }
      });
    }
  }

  Future<void> _submitSession() async {
    // 1. Validation du formulaire (champs vides, etc.)
    if (!_formKey.currentState!.validate()) return;

    // 2. Vérifications de sécurité (Formation et Dates)
    if (_selectedFormation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une formation"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedDateDebut == null || _selectedTimeDebut == null ||
        _selectedDateFin == null || _selectedTimeFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner les dates de début et fin"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Récupération de l'ID utilisateur
    final int? userId = await UserPrefs.getUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : utilisateur non connecté"), backgroundColor: Colors.red),
      );
      return;
    }

    // --- ÉTAPE GEOCODING : Conversion Adresse -> Coordonnées ---
    double latitude = 0.0;
    double longitude = 0.0;

    // On ne cherche les coordonnées que pour le Présentiel
    if (_selectedType == 'Présentiel') {
      try {
        List<Location> locations = await locationFromAddress(_lieuController.text.trim());
        if (locations.isNotEmpty) {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        }
      } catch (e) {
        // Si l'adresse est invalide ou introuvable
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📍 Adresse introuvable. Soyez plus précis (n°, rue, ville)."),
            backgroundColor: Colors.orange,
          ),
        );
        return; // On arrête tout si on ne peut pas localiser le présentiel
      }
    }
    print("DEBUG GPS -> Lat: $latitude, Lng: $longitude");

    // 4. Combinaison des dates et heures
    final dateTimeDebut = DateTime(
      _selectedDateDebut!.year, _selectedDateDebut!.month, _selectedDateDebut!.day,
      _selectedTimeDebut!.hour, _selectedTimeDebut!.minute,
    );
    final dateTimeFin = DateTime(
      _selectedDateFin!.year, _selectedDateFin!.month, _selectedDateFin!.day,
      _selectedTimeFin!.hour, _selectedTimeFin!.minute,
    );

    final formattedDebut = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeDebut);
    final formattedFin = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeFin);

    // 5. Envoi final au Service Admin (avec Lat et Lng !)
    final bool success = await _adminService.createSession(
      userId,
      _selectedFormation!.idFormation,
      _selectedType,
      _lieuController.text.trim(),
      formattedDebut,
      formattedFin,
      latitude, // <--- Nouveau paramètre
      longitude, // <--- Nouveau paramètre
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Session créée avec succès !"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la création sur le serveur"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _lieuController.dispose();
    _latController.dispose();
    _lngController.dispose();
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

                    // --- Date et Heure de DÉBUT ---
                    _buildLabel("Date et heure de début"),
                    const SizedBox(height: 8),
                    _buildDateTimeRow(
                      date: _selectedDateDebut,
                      time: _selectedTimeDebut,
                      onPickDate: () => _pickDate(isDebut: true),
                      onPickTime: () => _pickTime(isDebut: true),
                    ),
                    const SizedBox(height: 20),

                    // --- Date et Heure de FIN ---
                    _buildLabel("Date et heure de fin"),
                    const SizedBox(height: 8),
                    _buildDateTimeRow(
                      date: _selectedDateFin,
                      time: _selectedTimeFin,
                      onPickDate: () => _pickDate(isDebut: false),
                      onPickTime: () => _pickTime(isDebut: false),
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
                                  left: type == 'En ligne' ? 5 : 0),
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
                    const SizedBox(height: 25),

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

  Widget _buildDateTimeRow({
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onPickDate,
    required VoidCallback onPickTime,
  }) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onPickDate,
            child: Container(
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
                    date != null ? DateFormat('dd/MM/yyyy').format(date) : "Date",
                    style: TextStyle(
                      color: date != null ? Colors.black87 : Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onPickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Color(0xFF004AAD)),
                  const SizedBox(width: 10),
                  Text(
                    time != null ? time.format(context) : "Heure",
                    style: TextStyle(
                      color: time != null ? Colors.black87 : Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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